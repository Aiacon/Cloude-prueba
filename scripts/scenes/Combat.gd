extends Node2D
## Combate por turnos: iniciativa (d20+DES), acciones de ataque/objeto/huida,
## resolución de ataques y salvaciones según el motor de reglas D&D 3.5.

var party_alive: Array = []
var enemies: Array = []
var initiative_order: Array = []
var turn_index: int = 0
var current_actor = null
var encounter_room_id: String = ""
var encounter_id: String = ""
var return_pos: Vector2i

var log_lines: Array = []
const MAX_LOG_LINES := 8

var log_label: RichTextLabel
var enemy_status_label: Label
var party_status_label: Label
var action_panel: VBoxContainer
var target_panel: VBoxContainer
var end_panel: VBoxContainer
var end_label: Label


func _ready() -> void:
	var pending: Dictionary = GameManager.pending_encounter
	encounter_room_id = pending.get("room_id", "")
	encounter_id = pending.get("encounter_id", "")
	return_pos = GameManager.player_return_pos

	party_alive = GameManager.party.filter(func(c): return c.current_hp > 0)
	enemies = []
	for monster_id in pending.get("monster_ids", []):
		var enemy := MonsterDB.instantiate(monster_id)
		if enemy != null:
			enemies.append(enemy)

	initiative_order = CombatEngine.roll_initiative_order(party_alive + enemies)
	turn_index = 0

	_build_ui()
	EventBus.encounter_started.emit(enemies)
	_log("¡Comienza el combate!")
	_process_turn()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.size = Vector2(384, 216)
	add_child(bg)

	var ui := CanvasLayer.new()
	add_child(ui)

	enemy_status_label = Label.new()
	enemy_status_label.position = Vector2(8, 8)
	enemy_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	enemy_status_label.custom_minimum_size = Vector2(368, 0)
	ui.add_child(enemy_status_label)

	party_status_label = Label.new()
	party_status_label.position = Vector2(8, 60)
	party_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	party_status_label.custom_minimum_size = Vector2(368, 0)
	ui.add_child(party_status_label)

	log_label = RichTextLabel.new()
	log_label.position = Vector2(8, 96)
	log_label.size = Vector2(368, 60)
	log_label.bbcode_enabled = false
	log_label.scroll_active = false
	ui.add_child(log_label)

	action_panel = VBoxContainer.new()
	action_panel.position = Vector2(8, 160)
	ui.add_child(action_panel)
	_build_action_buttons()

	target_panel = VBoxContainer.new()
	target_panel.position = Vector2(140, 160)
	ui.add_child(target_panel)

	end_panel = VBoxContainer.new()
	end_panel.position = Vector2(90, 160)
	end_panel.visible = false
	ui.add_child(end_panel)
	end_label = Label.new()
	end_panel.add_child(end_label)
	var continue_btn := Button.new()
	continue_btn.text = "Continuar"
	continue_btn.pressed.connect(_on_end_continue_pressed)
	end_panel.add_child(continue_btn)

	_refresh_hud()


func _build_action_buttons() -> void:
	var attack_btn := Button.new()
	attack_btn.text = "Atacar"
	attack_btn.pressed.connect(_on_attack_pressed)
	action_panel.add_child(attack_btn)

	var item_btn := Button.new()
	item_btn.text = "Poción"
	item_btn.pressed.connect(_on_item_pressed)
	action_panel.add_child(item_btn)

	var flee_btn := Button.new()
	flee_btn.text = "Huir"
	flee_btn.pressed.connect(_on_flee_pressed)
	action_panel.add_child(flee_btn)


func _refresh_hud() -> void:
	var enemy_text := ""
	for e in enemies:
		var status: String = "en pie" if e.current_hp > 0 else "derrotado"
		enemy_text += "%s: %d/%d PG (%s)   " % [e.character_name, max(e.current_hp, 0), e.max_hp, status]
	enemy_status_label.text = enemy_text

	var party_text := ""
	for p in GameManager.party:
		var status: String = "en pie" if p.current_hp > 0 else "caído"
		party_text += "%s: %d/%d PG (%s)   " % [p.character_name, max(p.current_hp, 0), p.max_hp, status]
	party_status_label.text = party_text


func _log(text: String) -> void:
	log_lines.append(text)
	if log_lines.size() > MAX_LOG_LINES:
		log_lines.pop_front()
	log_label.text = "\n".join(log_lines)


func _check_end() -> bool:
	var enemies_alive := enemies.filter(func(e): return e.current_hp > 0)
	if enemies_alive.is_empty():
		_victory()
		return true
	var still_alive := GameManager.party.filter(func(p): return p.current_hp > 0)
	if still_alive.is_empty():
		_defeat()
		return true
	return false


func _process_turn() -> void:
	if _check_end():
		return
	if turn_index >= initiative_order.size():
		turn_index = 0

	var entry: Dictionary = initiative_order[turn_index]
	var combatant = entry["combatant"]

	if combatant.current_hp <= 0:
		turn_index += 1
		_process_turn()
		return

	action_panel.visible = false
	target_panel.visible = false
	for child in target_panel.get_children():
		child.queue_free()

	if enemies.has(combatant):
		get_tree().create_timer(0.6).timeout.connect(func(): _enemy_attack(combatant))
	else:
		current_actor = combatant
		_log("Turno de %s." % combatant.character_name)
		action_panel.visible = true


func _enemy_attack(attacker) -> void:
	var alive_targets := GameManager.party.filter(func(p): return p.current_hp > 0)
	if alive_targets.is_empty():
		_check_end()
		return
	var target = alive_targets[randi() % alive_targets.size()]
	var result := CombatEngine.resolve_attack(
		attacker.melee_attack_bonus(), target.armor_class(),
		attacker.weapon_damage_expression(), attacker.melee_damage_bonus()
	)
	if result.hit:
		target.take_damage(result.damage)
		var crit_text := " ¡CRÍTICO!" if result.critical else ""
		_log("%s golpea a %s por %d daño.%s" % [attacker.character_name, target.character_name, result.damage, crit_text])
	else:
		_log("%s falla el ataque contra %s." % [attacker.character_name, target.character_name])
	_refresh_hud()
	_end_turn()


func _on_attack_pressed() -> void:
	action_panel.visible = false
	target_panel.visible = true
	for e in enemies:
		if e.current_hp <= 0:
			continue
		var btn := Button.new()
		btn.text = "%s (%d/%d PG)" % [e.character_name, e.current_hp, e.max_hp]
		btn.pressed.connect(func(): _on_target_selected(e))
		target_panel.add_child(btn)


func _on_target_selected(target) -> void:
	var result := CombatEngine.resolve_attack(
		current_actor.melee_attack_bonus(), target.armor_class(),
		current_actor.weapon_damage_expression(), current_actor.melee_damage_bonus()
	)
	if result.hit:
		var bonus_dice := current_actor.sneak_attack_dice()
		var extra := 0
		if bonus_dice > 0:
			extra = Dice.roll_multiple(bonus_dice, 6)
		var total_damage: int = result.damage + extra
		target.take_damage(total_damage)
		var crit_text := " ¡CRÍTICO!" if result.critical else ""
		var sneak_text := (" (+%d furtivo)" % extra) if extra > 0 else ""
		_log("%s golpea a %s por %d daño.%s%s" % [current_actor.character_name, target.character_name, total_damage, crit_text, sneak_text])
	else:
		_log("%s falla el ataque contra %s." % [current_actor.character_name, target.character_name])
	_refresh_hud()
	target_panel.visible = false
	_end_turn()


func _on_item_pressed() -> void:
	var leader: Character = GameManager.party[0]
	if not leader.inventory.has_item("pocion_curacion_leve"):
		_log("No quedan pociones de curación.")
		return
	leader.inventory.remove_item("pocion_curacion_leve")
	var healed := Dice.roll_expression("1d8+1")
	current_actor.heal(healed)
	_log("%s bebe una poción y recupera %d PG." % [current_actor.character_name, healed])
	_refresh_hud()
	_end_turn()


func _on_flee_pressed() -> void:
	var roll := Dice.d20() + current_actor.abilities.dex_mod()
	if roll >= 11:
		_log("¡%s logra huir del combate!" % current_actor.character_name)
		_flee_combat()
	else:
		_log("%s intenta huir... ¡pero no lo consigue!" % current_actor.character_name)
		_end_turn()


func _end_turn() -> void:
	current_actor = null
	turn_index += 1
	get_tree().create_timer(0.4).timeout.connect(_process_turn)


func _flee_combat() -> void:
	GameManager.player_return_pos = return_pos
	GameManager.return_to_dungeon()


func _victory() -> void:
	action_panel.visible = false
	target_panel.visible = false

	var total_xp := 0
	var total_gold := 0
	for e in enemies:
		total_xp += int(e.get_meta("xp_reward", 0))
		total_gold += e.inventory.gold

	if encounter_room_id != "" and encounter_id != "":
		GameManager.cleared_encounters["%s:%s" % [encounter_room_id, encounter_id]] = true

	var leader: Character = GameManager.party[0]
	leader.inventory.add_gold(total_gold)

	for member in GameManager.party:
		if member.current_hp <= 0:
			continue
		member.experience += total_xp
		var xp_to_next := member.level * 1000
		while member.experience >= xp_to_next:
			member.experience -= xp_to_next
			member.level_up()
			xp_to_next = member.level * 1000

	end_label.text = "¡Victoria! +%d XP, +%d oro." % [total_xp, total_gold]
	GameManager.player_return_pos = return_pos
	end_panel.visible = true


func _defeat() -> void:
	action_panel.visible = false
	target_panel.visible = false
	end_label.text = "El grupo ha caído en el Templo Elemental...\nCarga tu última partida guardada para continuar."
	end_panel.visible = true


func _on_end_continue_pressed() -> void:
	if GameManager.is_party_alive():
		GameManager.return_to_dungeon()
	else:
		get_tree().change_scene_to_file(GameManager.SCENE_MAIN_MENU)
