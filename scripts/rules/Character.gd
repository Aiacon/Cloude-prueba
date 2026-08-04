extends RefCounted
## Personaje jugable o PNJ: combina raza, clase, atributos y equipo (reglas D&D 3.5 simplificadas).
class_name Character

var character_name: String = "Aventurero"
var race_id: String = "human"
var class_id: String = "fighter"
var level: int = 1
var abilities: AbilityScores
var max_hp: int = 1
var current_hp: int = 1
var base_armor_bonus: int = 0   # de la armadura equipada
var shield_bonus: int = 0
var feats: Array = []
var skill_ranks: Dictionary = {}   # skill_name -> ranks
var equipment: Dictionary = {"weapon": null, "armor": null, "shield": null, "ring": null, "amulet": null}
var inventory: Inventory = null
var is_alive: bool = true
var experience: int = 0
var current_mana: int = 0   # Puntos de Maná actuales (se inicializan al máximo al crear el personaje)
var temp_ac_bonus: int = 0       # bonificadores de conjuros de buff/debuff, solo duran el combate
var temp_attack_bonus: int = 0


static func create_new(name: String, race_id_: String, class_id_: String, abilities_: AbilityScores) -> Character:
	var c := Character.new()
	c.character_name = name
	c.race_id = race_id_
	c.class_id = class_id_
	c.level = 1
	c.abilities = abilities_
	var race := RaceDB.get_race(race_id_)
	c.abilities.apply_racial_adjustments(race.get("ability_adjustments", {}))
	c.inventory = Inventory.new()
	c.roll_hit_points_for_level_up()
	c.current_hp = c.max_hp
	if race.get("bonus_feat", false):
		c._grant_feat()
	c._equip_starting_gear()
	c.current_mana = c.max_mana()
	return c


## Equipa el arma/armadura/escudo inicial típico de la clase.
func _equip_starting_gear() -> void:
	var data := class_data()
	var weapon_id: String = data.get("starting_weapon", "")
	if weapon_id != "":
		equip_weapon(weapon_id)
	var armor_id: String = data.get("starting_armor", "")
	if armor_id != "":
		equip_armor(armor_id)
	var shield_id: String = data.get("starting_shield", "")
	if shield_id != "":
		equip_shield(shield_id)


func equip_weapon(item_id: String) -> void:
	var item := ItemDB.get_item(item_id)
	if item.is_empty():
		return
	equipment["weapon"] = {"item_id": item_id, "name": item["name"], "damage": item["damage"], "hands": item["hands"]}


func equip_armor(item_id: String) -> void:
	var item := ItemDB.get_item(item_id)
	if item.is_empty():
		return
	equipment["armor"] = {"item_id": item_id, "name": item["name"]}
	base_armor_bonus = item.get("ac_bonus", 0)


func equip_shield(item_id: String) -> void:
	var item := ItemDB.get_item(item_id)
	if item.is_empty():
		return
	equipment["shield"] = {"item_id": item_id, "name": item["name"]}
	shield_bonus = item.get("ac_bonus", 0)


## Equipa un objeto mágico (arma/armadura/escudo/anillo/objeto maravilloso) de MagicItemDB.
func equip_magic_item(item_id: String) -> void:
	var item := MagicItemDB.get_item(item_id)
	if item.is_empty():
		return
	var slot: String
	match item["type"]:
		"weapon": slot = "weapon"
		"armor": slot = "armor"
		"shield": slot = "shield"
		"ring": slot = "ring"
		"wondrous": slot = "amulet"
		_: return
	var base_item: Dictionary = ItemDB.get_item(item.get("base_item", ""))
	equipment[slot] = {
		"item_id": item_id, "name": item["name"], "magic": true,
		"damage": base_item.get("damage", "1d3"), "hands": base_item.get("hands", "melee"),
	}
	if slot == "armor":
		base_armor_bonus = base_item.get("ac_bonus", 0)
	elif slot == "shield":
		shield_bonus = base_item.get("ac_bonus", 0)


## Suma los bonificadores numéricos de todo el equipo mágico llevado puesto para "key".
func magic_item_bonus(key: String) -> int:
	var total := 0
	for slot in ["weapon", "armor", "shield", "ring", "amulet"]:
		var equipped = equipment.get(slot)
		if equipped == null or not equipped.get("magic", false):
			continue
		var item_data := MagicItemDB.get_item(equipped.get("item_id", ""))
		total += item_data.get("effect", {}).get(key, 0)
	return total


func class_data() -> Dictionary:
	return ClassDB.get_class(class_id)


func race_data() -> Dictionary:
	return RaceDB.get_race(race_id)


## Al subir de nivel se tira el dado de golpe de la clase + mod. CON (mínimo 1).
func roll_hit_points_for_level_up() -> void:
	var hd: int = class_data()["hit_die"]
	var roll: int = Dice.roll(hd)
	var gained: int = max(1, roll + abilities.con_mod())
	max_hp += gained
	current_hp = max_hp


## Sube de nivel: PG, dotes (generales y de bonificación de Guerrero cada N niveles),
## incremento de característica cada 4 niveles y progresión de conjuros si corresponde.
func level_up() -> void:
	level += 1
	roll_hit_points_for_level_up()

	if ProgressionDB.grants_ability_increase(level):
		_apply_ability_increase()

	if ProgressionDB.grants_general_feat(level):
		_grant_feat()
	if class_id == "fighter" and ProgressionDB.grants_fighter_bonus_feat(level):
		_grant_feat()

	current_mana = max_mana()
	EventBus.party_member_leveled_up.emit(self)


func _apply_ability_increase() -> void:
	match ClassDB.primary_ability(class_id):
		"str": abilities.strength += 1
		"dex": abilities.dexterity += 1
		"con": abilities.constitution += 1
		"int": abilities.intelligence += 1
		"wis": abilities.wisdom += 1
		"cha": abilities.charisma += 1


func _grant_feat() -> void:
	var feat_id := FeatDB.pick_feat_for(self)
	if feat_id == "":
		return
	feats.append(feat_id)
	var hp_gain: int = FeatDB.get_feat(feat_id).get("effects", {}).get("hp_bonus", 0)
	if hp_gain > 0:
		max_hp += hp_gain
		current_hp += hp_gain


## Suma los bonificadores numéricos de todas las dotes que posee el personaje para "key"
## (p.ej. "attack_bonus", "ac_bonus", "fort_bonus", "damage_bonus", "spell_dc_bonus"...).
func feat_bonus(key: String) -> int:
	var total := 0
	for feat_id in feats:
		total += FeatDB.get_feat(feat_id).get("effects", {}).get(key, 0)
	return total


func caster_level() -> int:
	return ClassDB.caster_level(class_id, level)


func is_spellcaster() -> bool:
	return class_data().get("casts_spells", false) and caster_level() > 0


func max_mana() -> int:
	return ClassDB.mana_per_day(class_id, level)


func known_spells() -> Array:
	if not is_spellcaster():
		return []
	return SpellDB.known_spells_for(class_id, level)


## CD de salvación de un conjuro de nivel "spell_level" lanzado por este personaje.
func spell_save_dc(spell_level: int) -> int:
	var ability_mod := 0
	match class_data().get("spellcasting_ability", ""):
		"int": ability_mod = abilities.int_mod()
		"wis": ability_mod = abilities.wis_mod()
		"cha": ability_mod = abilities.cha_mod()
	return 10 + spell_level + ability_mod + spell_save_dc_bonus() + magic_item_bonus("spell_dc_bonus")


## Gasta "cost" Puntos de Maná; devuelve false si no hay suficientes.
func spend_mana(cost: int) -> bool:
	if current_mana < cost:
		return false
	current_mana -= cost
	return true


## Descanso completo: restaura PG y Puntos de Maná (no distingue inconsciencia de muerte,
## por simplicidad "retro" cualquier personaje con 0 PG puede recuperarse al descansar).
func rest() -> void:
	current_hp = max_hp
	current_mana = max_mana()
	is_alive = true


func base_attack_bonus() -> int:
	return ClassDB.base_attack_bonus(class_data()["bab_progression"], level)


func fortitude_save() -> int:
	if has_meta("fort_override"):
		return get_meta("fort_override")
	return ClassDB.base_save_bonus(class_data()["fort_progression"], level) + abilities.con_mod() + feat_bonus("fort_bonus") + race_bonus("fort_bonus") + magic_item_bonus("fort_bonus")


func reflex_save() -> int:
	if has_meta("ref_override"):
		return get_meta("ref_override")
	return ClassDB.base_save_bonus(class_data()["ref_progression"], level) + abilities.dex_mod() + feat_bonus("ref_bonus") + race_bonus("ref_bonus") + magic_item_bonus("ref_bonus")


func will_save() -> int:
	if has_meta("will_override"):
		return get_meta("will_override")
	return ClassDB.base_save_bonus(class_data()["will_progression"], level) + abilities.wis_mod() + feat_bonus("will_bonus") + race_bonus("will_bonus") + magic_item_bonus("will_bonus")


## Clase de Armadura = 10 + Destreza + armadura + escudo + tamaño + dotes + objetos mágicos.
func armor_class() -> int:
	var size_mod := RaceDB.size_ac_modifier(race_data().get("size", "Medio"))
	return 10 + abilities.dex_mod() + base_armor_bonus + shield_bonus + size_mod + feat_bonus("ac_bonus") + magic_item_bonus("ac_bonus") + temp_ac_bonus


## Bonificador de ataque cuerpo a cuerpo: BAB + FUE + tamaño + dotes + objetos mágicos.
func melee_attack_bonus() -> int:
	if has_meta("attack_bonus_override"):
		return get_meta("attack_bonus_override")
	var size_mod := RaceDB.size_attack_modifier(race_data().get("size", "Medio"))
	return base_attack_bonus() + abilities.str_mod() + size_mod + feat_bonus("attack_bonus") + magic_item_bonus("attack_bonus") + temp_attack_bonus


## Bonificador de ataque a distancia: BAB + DES + tamaño + dotes + objetos mágicos.
func ranged_attack_bonus() -> int:
	var size_mod := RaceDB.size_attack_modifier(race_data().get("size", "Medio"))
	return base_attack_bonus() + abilities.dex_mod() + size_mod + feat_bonus("attack_bonus") + feat_bonus("ranged_attack_bonus") + magic_item_bonus("attack_bonus") + temp_attack_bonus


func race_bonus(key: String) -> int:
	return race_data().get("effects", {}).get(key, 0)


func weapon_damage_expression() -> String:
	if equipment.get("weapon") != null:
		return equipment["weapon"]["damage"]
	return "1d3"  # golpe sin arma


func melee_damage_bonus() -> int:
	return abilities.str_mod() + feat_bonus("damage_bonus") + magic_item_bonus("damage_bonus")


func sneak_attack_dice() -> int:
	return ClassDB.sneak_attack_dice(class_id, level)


func sneak_attack_flat_bonus() -> int:
	return feat_bonus("sneak_attack_bonus")


func spell_save_dc_bonus() -> int:
	return feat_bonus("spell_dc_bonus")


func heal_bonus() -> int:
	return feat_bonus("heal_bonus")


func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	if current_hp <= 0:
		is_alive = false


func heal(amount: int) -> void:
	current_hp = min(max_hp, current_hp + amount)
	if current_hp > 0:
		is_alive = true


func to_dict() -> Dictionary:
	return {
		"name": character_name, "race": race_id, "class": class_id, "level": level,
		"abilities": abilities.to_dict(), "max_hp": max_hp, "current_hp": current_hp,
		"base_armor_bonus": base_armor_bonus, "shield_bonus": shield_bonus,
		"feats": feats, "skill_ranks": skill_ranks, "equipment": equipment,
		"inventory": inventory.to_dict() if inventory else {}, "experience": experience,
		"current_mana": current_mana,
	}


static func from_dict(d: Dictionary) -> Character:
	var c := Character.new()
	c.character_name = d.get("name", "Aventurero")
	c.race_id = d.get("race", "human")
	c.class_id = d.get("class", "fighter")
	c.level = d.get("level", 1)
	c.abilities = AbilityScores.from_dict(d.get("abilities", {}))
	c.max_hp = d.get("max_hp", 1)
	c.current_hp = d.get("current_hp", 1)
	c.base_armor_bonus = d.get("base_armor_bonus", 0)
	c.shield_bonus = d.get("shield_bonus", 0)
	c.feats = d.get("feats", [])
	c.skill_ranks = d.get("skill_ranks", {})
	c.equipment = d.get("equipment", {"weapon": null, "armor": null, "shield": null, "ring": null, "amulet": null})
	c.inventory = Inventory.from_dict(d.get("inventory", {}))
	c.experience = d.get("experience", 0)
	c.current_mana = d.get("current_mana", 0)
	c.is_alive = c.current_hp > 0
	return c
