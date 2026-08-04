extends Node2D
## Combate por turnos: iniciativa (d20+DES), acciones de ataque/conjuro/objeto/huida,
## con el desglose de cada tirada visible en el registro y recompensas detalladas
## (oro, XP y objetos) por cada enemigo derrotado.

var party_alive: Array = []
var enemies: Array = []
var initiative_order: Array = []
var turn_index: int = 0
var current_actor = null
var encounter_room_id: String = ""
var encounter_id: String = ""
var return_pos: Vector2i

var log_lines: Array = []
const MAX_LOG_LINES := 9

var log_label: RichTextLabel
var enemy_status_label: Label
var party_status_label: Label
var action_panel: VBoxContainer
var target_panel: VBoxContainer
var spell_panel: VBoxContainer
var spell_scroll: ScrollContainer
var end_panel: VBoxContainer
var end_label: Label

var spell_action_btn: Button


func _ready() -> void:
	var pending: Dictionary = GameManager.pending_encounter
	encounter_room_id = pending.get("room_id", "")
	encounter_id = pending.get("encounter_id", "")
	return_pos = GameManager.player_return_pos

	party_alive = GameManager.party.filter(func(c): return c.current_hp > 0)
	for member in party_alive:
		member.temp_ac_bonus = 0
		member.temp_attack_bonus = 0

	enemies = []
	for monster_id in pending.get("monster_ids", []):
		var enemy := MonsterDB.instantiate(monster_id)
		if enemy != null:
			enemies.append(enemy)

	initiative_order = CombatEngine.roll_initiative_order(party_alive + enemies)
	turn_index = 0

	_build_ui()
	EventBus.encounter_started.emit(enemies)
	_log("¡Comienza el combate! Orden de iniciativa:")
	for entry in initiative_order:
		_log("  %s: %s" % [entry["combatant"].character_name, entry["breakdown"]])
	_process_turn()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.size = Vector2(384, 216)
	add_child(bg)

	var ui := CanvasLayer.new()
	add_child(ui)

	enemy_status_label = Label.new()
	enemy_status_label.position = Vector2(8, 4)
	enemy_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	enemy_status_label.custom_minimum_size = Vector2(368, 0)
	ui.add_child(enemy_status_label)

	party_status_label = Label.new()
	party_status_label.position = Vector2(8, 44)
	party_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	party_status_label.custom_minimum_size = Vector2(368, 0)
	ui.add_child(party_status_label)

	log_label = RichTextLabel.new()
	log_label.position = Vector2(8, 84)
	log_label.size = Vector2(368, 66)
	log_label.bbcode_enabled = false
	log_label.scroll_active = false
	ui.add_child(log_label)

	action_panel = VBoxContainer.new()
	action_panel.position = Vector2(8, 160)
	ui.add_child(action_panel)
	_build_action_buttons()

	target_panel = VBoxContainer.new()
	target_panel.position = Vector2(120, 160)
	ui.add_child(target_panel)

	spell_scroll = ScrollContainer.new()
	spell_scroll.position = Vector2(120, 160)
	spell_scroll.custom_minimum_size = Vector2(210, 52)
	spell_scroll.visible = false
	ui.add_child(spell_scroll)
	spell_panel = VBoxContainer.new()
	spell_scroll.add_child(spell_panel)

	end_panel = VBoxContainer.new()
	end_panel.position = Vector2(90, 160)
	end_panel.visible = false
	ui.add_child(end_panel)
	end_label = Label.new()
	end_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	end_label.custom_minimum_size = Vector2(220, 0)
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

	spell_action_btn = Button.new()
	spell_action_btn.text = "Conjuro"
	spell_action_btn.pressed.connect(_on_spell_menu_pressed)
	action_panel.add_child(spell_action_btn)

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
		var mana_text := (" %d/%d PM" % [p.current_mana, p.max_mana()]) if p.is_spellcaster() else ""
		party_text += "%s: %d/%d PG%s (%s)   " % [p.character_name, max(p.current_hp, 0), p.max_hp, mana_text, status]
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
	spell_scroll.visible = false
	for child in target_panel.get_children():
		child.queue_free()
	for child in spell_panel.get_children():
		child.queue_free()

	if enemies.has(combatant):
		get_tree().create_timer(0.6).timeout.connect(func(): _enemy_attack(combatant))
	else:
		current_actor = combatant
		_log("Turno de %s." % combatant.character_name)
		spell_action_btn.visible = combatant.is_spellcaster() and combatant.current_mana > 0
		action_panel.visible = true


func _attack_bonus_for(actor) -> int:
	var weapon = actor.equipment.get("weapon")
	if weapon != null and weapon.get("hands", "melee") == "ranged":
		return actor.ranged_attack_bonus()
	return actor.melee_attack_bonus()


func _enemy_attack(attacker) -> void:
	var alive_targets := GameManager.party.filter(func(p): return p.current_hp > 0)
	if alive_targets.is_empty():
		_check_end()
		return
	var target = alive_targets[randi() % alive_targets.size()]
	var result := CombatEngine.resolve_attack(
		_attack_bonus_for(attacker), target.armor_class(),
		attacker.weapon_damage_expression(), attacker.melee_damage_bonus()
	)
	_log("%s ataca a %s: %s" % [attacker.character_name, target.character_name, result.breakdown])
	if result.hit:
		target.take_damage(result.damage)
		var crit_text := " ¡CRÍTICO!" if result.critical else ""
		_log("  ¡Impacto! %d de daño.%s" % [result.damage, crit_text])
	else:
		_log("  Falla el ataque.")
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
		_attack_bonus_for(current_actor), target.armor_class(),
		current_actor.weapon_damage_expression(), current_actor.melee_damage_bonus()
	)
	_log("%s ataca a %s: %s" % [current_actor.character_name, target.character_name, result.breakdown])
	if result.hit:
		var sneak_dice := current_actor.sneak_attack_dice()
		var extra := 0
		if sneak_dice > 0:
			extra = Dice.roll_multiple(sneak_dice, 6) + current_actor.sneak_attack_flat_bonus()
		var total_damage: int = result.damage + extra
		target.take_damage(total_damage)
		var crit_text := " ¡CRÍTICO!" if result.critical else ""
		var sneak_text := (" (+%d furtivo)" % extra) if extra > 0 else ""
		_log("  ¡Impacto! %d de daño.%s%s" % [total_damage, crit_text, sneak_text])
	else:
		_log("  Falla el ataque.")
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


## --- Conjuros ---

func _on_spell_menu_pressed() -> void:
	action_panel.visible = false
	spell_scroll.visible = true
	var mana_lbl := Label.new()
	mana_lbl.text = "Maná: %d/%d" % [current_actor.current_mana, current_actor.max_mana()]
	spell_panel.add_child(mana_lbl)
	for spell_id in current_actor.known_spells():
		var spell := SpellDB.get_spell(spell_id)
		var cost := SpellDB.mana_cost(spell["level"])
		var btn := Button.new()
		btn.text = "Nv%d %s (%d PM)" % [spell["level"], spell["name"], cost]
		btn.disabled = current_actor.current_mana < cost
		btn.pressed.connect(func(): _on_spell_selected(spell_id))
		spell_panel.add_child(btn)
	if current_actor.known_spells().is_empty():
		var lbl := Label.new()
		lbl.text = "No conoces conjuros todavía."
		spell_panel.add_child(lbl)


func _on_spell_selected(spell_id: String) -> void:
	var spell := SpellDB.get_spell(spell_id)
	spell_scroll.visible = false

	match spell["target"]:
		"self":
			_cast_spell(spell_id, [current_actor])
		"ally":
			target_panel.visible = true
			for p in GameManager.party:
				if p.current_hp <= 0:
					continue
				var btn := Button.new()
				btn.text = "%s (%d/%d PG)" % [p.character_name, p.current_hp, p.max_hp]
				btn.pressed.connect(func(): _cast_spell(spell_id, [p]))
				target_panel.add_child(btn)
		"enemy":
			target_panel.visible = true
			for e in enemies:
				if e.current_hp <= 0:
					continue
				var btn := Button.new()
				btn.text = "%s (%d/%d PG)" % [e.character_name, e.current_hp, e.max_hp]
				btn.pressed.connect(func(): _cast_spell(spell_id, [e]))
				target_panel.add_child(btn)
		"all_enemies":
			_cast_spell(spell_id, enemies.filter(func(e): return e.current_hp > 0))


func _cast_spell(spell_id: String, targets: Array) -> void:
	var spell := SpellDB.get_spell(spell_id)
	var cost := SpellDB.mana_cost(spell["level"])
	if not current_actor.spend_mana(cost):
		_log("%s no tiene suficientes Puntos de Maná (%d PM)." % [current_actor.character_name, cost])
		return
	var dc := current_actor.spell_save_dc(spell["level"])
	_log("%s lanza %s (%d PM)." % [current_actor.character_name, spell["name"], cost])

	for target in targets:
		match spell["effect"]:
			"damage":
				_resolve_spell_damage(spell, target, dc)
			"heal":
				var healed: int = max(1, Dice.roll_expression(spell["expression"]) + current_actor.heal_bonus())
				target.heal(healed)
				_log("  %s recupera %d PG." % [target.character_name, healed])
			"buff_ac":
				var bonus: int = int(spell["expression"])
				target.temp_ac_bonus += bonus
				_log("  %s gana +%d a la CA." % [target.character_name, bonus])
			"buff_attack":
				var bonus2: int = int(spell["expression"])
				target.temp_attack_bonus += bonus2
				_log("  %s gana +%d a los ataques." % [target.character_name, bonus2])
			"debuff_ac":
				var penalty: int = int(spell["expression"])
				target.temp_ac_bonus -= penalty
				_log("  %s sufre -%d a la CA." % [target.character_name, penalty])

	target_panel.visible = false
	_refresh_hud()
	_end_turn()


func _resolve_spell_damage(spell: Dictionary, target, dc: int) -> void:
	var dmg: int = max(1, Dice.roll_expression(spell["expression"]))
	var save_type: String = spell.get("save", "none")
	if save_type != "none":
		var save_bonus: int = target.fortitude_save() if save_type == "fort" else (target.reflex_save() if save_type == "ref" else target.will_save())
		var save_result := CombatEngine.resolve_save(save_bonus, dc)
		_log("  %s salva (%s): %s" % [target.character_name, save_type.to_upper(), save_result.breakdown])
		if save_result.success:
			dmg = int(dmg / 2.0)
			_log("  ¡Salvación superada! Daño reducido a la mitad.")
	target.take_damage(dmg)
	_log("  %s recibe %d de daño." % [target.character_name, dmg])


## --- Huida ---

func _on_flee_pressed() -> void:
	var roll := Dice.d20() + current_actor.abilities.dex_mod()
	if roll >= 11:
		_log("¡%s logra huir del combate! (d20 + DES = %d)" % [current_actor.character_name, roll])
		_flee_combat()
	else:
		_log("%s intenta huir... ¡pero no lo consigue! (d20 + DES = %d)" % [current_actor.character_name, roll])
		_end_turn()


func _end_turn() -> void:
	current_actor = null
	turn_index += 1
	get_tree().create_timer(0.4).timeout.connect(_process_turn)


func _flee_combat() -> void:
	GameManager.player_return_pos = return_pos
	GameManager.return_to_dungeon()


## --- Fin de combate ---

func _victory() -> void:
	action_panel.visible = false
	target_panel.visible = false
	spell_scroll.visible = false

	var total_xp := 0
	var total_gold := 0
	var loot_lines: Array = []
	var leader: Character = GameManager.party[0]

	for e in enemies:
		var monster_id: String = e.get_meta("monster_id", "")
		var xp: int = int(e.get_meta("xp_reward", 0))
		var gold: int = e.inventory.gold
		total_xp += xp
		total_gold += gold
		var drops := MonsterDB.roll_loot(monster_id)
		for drop in drops:
			if drop["source"] == "magic" and MagicItemDB.is_equippable(drop["item_id"]):
				leader.equip_magic_item(drop["item_id"])
				loot_lines.append("%s equipa: %s" % [leader.character_name, drop["name"]])
			else:
				leader.inventory.add_item(drop["item_id"], 1)
				loot_lines.append("Botín: %s" % drop["name"])

	if encounter_room_id != "" and encounter_id != "":
		GameManager.cleared_encounters["%s:%s" % [encounter_room_id, encounter_id]] = true

	leader.inventory.add_gold(total_gold)

	var level_up_lines: Array = []
	for member in GameManager.party:
		if member.current_hp <= 0:
			continue
		member.experience += total_xp
		while member.level < ProgressionDB.MAX_LEVEL and member.experience >= ProgressionDB.xp_for_level(member.level + 1):
			member.level_up()
			level_up_lines.append("%s alcanza el nivel %d." % [member.character_name, member.level])

	var victory_text := "¡Victoria! +%d XP, +%d oro." % [total_xp, total_gold]
	for line in loot_lines:
		victory_text += "\n" + line
	for line in level_up_lines:
		victory_text += "\n" + line
	end_label.text = victory_text
	GameManager.player_return_pos = return_pos
	end_panel.visible = true


func _defeat() -> void:
	action_panel.visible = false
	target_panel.visible = false
	spell_scroll.visible = false
	end_label.text = "El grupo ha caído en el Templo Elemental...\nCarga tu última partida guardada para continuar."
	end_panel.visible = true


func _on_end_continue_pressed() -> void:
	if GameManager.is_party_alive():
		GameManager.return_to_dungeon()
	else:
		get_tree().change_scene_to_file(GameManager.SCENE_MAIN_MENU)
