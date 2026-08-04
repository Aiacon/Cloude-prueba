extends Node2D
## Controlador de la sala explorable: construye el mapa, mueve al jugador y resuelve
## puertas, portales, encuentros y recolectables.

var dungeon_builder: DungeonBuilder
var player: Player
var camera: Camera2D

var room_name_label: Label
var party_status_label: Label
var message_label: Label
var message_timer: Timer

var talk_btn: Button
var nearby_npc: Dictionary = {}
var dialogue_panel: PanelContainer
var dialogue_label: Label
var dialogue_buttons: VBoxContainer


func _ready() -> void:
	dungeon_builder = DungeonBuilder.new()
	add_child(dungeon_builder)

	player = Player.new()
	player.dungeon = dungeon_builder
	player.tile_entered.connect(_on_player_tile_entered)
	add_child(player)

	camera = Camera2D.new()
	camera.zoom = Vector2(1.0, 1.0)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	player.add_child(camera)
	camera.make_current()

	_build_ui()

	var start_room: String = GameManager.current_level_id
	var spawn: Vector2i
	if GameManager.player_return_pos != Vector2i(-1, -1):
		spawn = GameManager.player_return_pos
		GameManager.player_return_pos = Vector2i(-1, -1)
	else:
		var room_data := LevelData.get_room(start_room)
		spawn = Vector2i(room_data["start_pos"]["x"], room_data["start_pos"]["y"])

	dungeon_builder.load_room(start_room, spawn)
	player.place_at(spawn)
	_refresh_hud()
	_update_nearby_npc(spawn)

	EventBus.game_message.connect(_show_message)


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	room_name_label = Label.new()
	room_name_label.position = Vector2(8, 4)
	ui.add_child(room_name_label)

	party_status_label = Label.new()
	party_status_label.position = Vector2(8, 20)
	ui.add_child(party_status_label)

	message_label = Label.new()
	message_label.position = Vector2(8, 190)
	message_label.modulate = Color(1, 0.9, 0.4)
	ui.add_child(message_label)

	message_timer = Timer.new()
	message_timer.one_shot = true
	message_timer.wait_time = 2.5
	message_timer.timeout.connect(func(): message_label.text = "")
	ui.add_child(message_timer)

	var save_btn := Button.new()
	save_btn.text = "Guardar"
	save_btn.position = Vector2(300, 4)
	save_btn.pressed.connect(_on_save_pressed)
	ui.add_child(save_btn)

	var menu_btn := Button.new()
	menu_btn.text = "Menú"
	menu_btn.position = Vector2(300, 32)
	menu_btn.pressed.connect(_on_menu_pressed)
	ui.add_child(menu_btn)

	var rest_btn := Button.new()
	rest_btn.text = "Descansar"
	rest_btn.position = Vector2(300, 60)
	rest_btn.pressed.connect(_on_rest_pressed)
	ui.add_child(rest_btn)

	talk_btn = Button.new()
	talk_btn.text = "Hablar"
	talk_btn.position = Vector2(300, 88)
	talk_btn.visible = false
	talk_btn.pressed.connect(_on_talk_pressed)
	ui.add_child(talk_btn)

	_build_dpad(ui)
	_build_dialogue_panel(ui)


func _build_dialogue_panel(ui: CanvasLayer) -> void:
	dialogue_panel = PanelContainer.new()
	dialogue_panel.position = Vector2(24, 40)
	dialogue_panel.custom_minimum_size = Vector2(336, 130)
	dialogue_panel.visible = false
	ui.add_child(dialogue_panel)

	var box := VBoxContainer.new()
	dialogue_panel.add_child(box)

	dialogue_label = Label.new()
	dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	dialogue_label.custom_minimum_size = Vector2(320, 60)
	box.add_child(dialogue_label)

	dialogue_buttons = VBoxContainer.new()
	box.add_child(dialogue_buttons)


func _build_dpad(ui: CanvasLayer) -> void:
	var dpad_origin := Vector2(16, 140)
	var btn_size := Vector2(24, 24)

	var up_btn := _make_dpad_button("▲", dpad_origin + Vector2(28, 0), btn_size, Vector2i.UP)
	var down_btn := _make_dpad_button("▼", dpad_origin + Vector2(28, 48), btn_size, Vector2i.DOWN)
	var left_btn := _make_dpad_button("◀", dpad_origin + Vector2(0, 24), btn_size, Vector2i.LEFT)
	var right_btn := _make_dpad_button("▶", dpad_origin + Vector2(56, 24), btn_size, Vector2i.RIGHT)
	for b in [up_btn, down_btn, left_btn, right_btn]:
		ui.add_child(b)


func _make_dpad_button(label: String, pos: Vector2, btn_size: Vector2, dir: Vector2i) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.position = pos
	btn.size = btn_size
	btn.button_down.connect(func(): player.set_input_direction(dir))
	btn.button_up.connect(func():
		if player.pending_direction == dir:
			player.set_input_direction(Vector2i.ZERO)
	)
	return btn


func _on_player_tile_entered(pos: Vector2i) -> void:
	_update_nearby_npc(pos)

	if dungeon_builder.doors_by_pos.has(pos):
		var door: Dictionary = dungeon_builder.doors_by_pos[pos]
		_transition_to(door["target_room"], _to_v2i(door["target_pos"]))
		return

	if dungeon_builder.portals_by_pos.has(pos):
		var portal: Dictionary = dungeon_builder.portals_by_pos[pos]
		var required: int = portal.get("required_keys", 0)
		if GameManager.keys_collected >= required:
			_transition_to(portal["target_room"], _to_v2i(portal["target_pos"]))
		else:
			EventBus.game_message.emit("El Nexo exige las 4 llaves elementales (%d/%d)." % [GameManager.keys_collected, required])
		return

	if dungeon_builder.encounters_by_pos.has(pos):
		var enc: Dictionary = dungeon_builder.encounters_by_pos[pos]
		GameManager.start_encounter(enc["monsters"], dungeon_builder.room_id, enc["id"], pos)
		return

	if dungeon_builder.pickups_by_pos.has(pos):
		_collect_pickup(dungeon_builder.pickups_by_pos[pos])
		return


func _transition_to(target_room: String, target_pos: Vector2i) -> void:
	dungeon_builder.load_room(target_room, target_pos)
	player.dungeon = dungeon_builder
	player.place_at(target_pos)
	_refresh_hud()
	_update_nearby_npc(target_pos)


func _collect_pickup(pickup: Dictionary) -> void:
	var key := "%s:%s" % [dungeon_builder.room_id, pickup["id"]]
	GameManager.collected_pickups[key] = true
	var item_id: String = pickup["item"]
	var quantity: int = pickup.get("quantity", 1)
	var leader: Character = GameManager.party[0]
	leader.inventory.add_item(item_id, quantity)
	if item_id.begins_with("llave_ala_"):
		GameManager.keys_collected += 1
	var item_data := ItemDB.get_item(item_id)
	EventBus.game_message.emit("Has obtenido: %s" % item_data.get("name", item_id))

	var current_pos: Vector2i = player.grid_pos
	dungeon_builder.load_room(dungeon_builder.room_id, current_pos)
	player.dungeon = dungeon_builder
	player.place_at(current_pos)
	_update_nearby_npc(current_pos)


func _refresh_hud() -> void:
	room_name_label.text = dungeon_builder.room_data.get("name", "")
	var status := ""
	for member in GameManager.party:
		status += "%s: %d/%d PG   " % [member.character_name, member.current_hp, member.max_hp]
	party_status_label.text = status


func _show_message(text: String) -> void:
	message_label.text = text
	message_timer.start()


func _on_save_pressed() -> void:
	if SaveSystem.save_game():
		_show_message("Partida guardada.")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(GameManager.SCENE_MAIN_MENU)


func _on_rest_pressed() -> void:
	GameManager.rest_party()
	_refresh_hud()


func _to_v2i(d: Dictionary) -> Vector2i:
	return Vector2i(d.get("x", 0), d.get("y", 0))


## --- NPC y diálogo ---

func _update_nearby_npc(pos: Vector2i) -> void:
	nearby_npc = dungeon_builder.adjacent_npc(pos)
	talk_btn.visible = not nearby_npc.is_empty()


func _npc_quest_id(npc: Dictionary) -> String:
	if npc["id"] == "hermano_ismael":
		return QuestDB.next_main_chain_quest()
	return npc.get("quest_id", "")


func _on_talk_pressed() -> void:
	if nearby_npc.is_empty():
		return
	var npc := nearby_npc
	var quest_id := _npc_quest_id(npc)

	if quest_id == "":
		_open_dialogue(npc["name"], npc["idle_lines"], [])
		return

	var quest := QuestDB.get_quest(quest_id)
	var state := QuestDB.state(quest_id)

	if state == "active":
		if QuestDB.is_objective_met(quest_id):
			GameManager.complete_quest(quest_id)
			_refresh_hud()
			_open_dialogue(npc["name"], quest["complete_text"], [])
		else:
			_open_dialogue(npc["name"], ["Misión activa: %s" % quest["name"], "Todavía no la has completado."], [])
	elif state == "completed":
		_open_dialogue(npc["name"], npc["idle_lines"], [])
	else:
		var accept_action := func():
			GameManager.accept_quest(quest_id)
			_close_dialogue()
		var options := [{"label": "Aceptar: %s" % quest["name"], "action": accept_action}]
		_open_dialogue(npc["name"], quest["offer_text"], options)


func _open_dialogue(speaker: String, lines: Array, options: Array) -> void:
	player.input_locked = true
	dialogue_label.text = "%s:\n\n%s" % [speaker, "\n".join(lines)]
	for child in dialogue_buttons.get_children():
		child.queue_free()
	for option in options:
		var btn := Button.new()
		btn.text = option["label"]
		btn.pressed.connect(option["action"])
		dialogue_buttons.add_child(btn)
	var close_btn := Button.new()
	close_btn.text = "Cerrar"
	close_btn.pressed.connect(_close_dialogue)
	dialogue_buttons.add_child(close_btn)
	dialogue_panel.visible = true


func _close_dialogue() -> void:
	dialogue_panel.visible = false
	player.input_locked = false
