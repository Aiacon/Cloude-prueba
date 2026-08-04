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
var equipment: Dictionary = {"weapon": null, "armor": null, "shield": null}
var inventory: Inventory = null
var is_alive: bool = true
var experience: int = 0


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
	return c


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


func level_up() -> void:
	level += 1
	roll_hit_points_for_level_up()
	EventBus.party_member_leveled_up.emit(self)


func base_attack_bonus() -> int:
	return ClassDB.base_attack_bonus(class_data()["bab_progression"], level)


func fortitude_save() -> int:
	if has_meta("fort_override"):
		return get_meta("fort_override")
	return ClassDB.base_save_bonus(class_data()["fort_progression"], level) + abilities.con_mod()


func reflex_save() -> int:
	if has_meta("ref_override"):
		return get_meta("ref_override")
	return ClassDB.base_save_bonus(class_data()["ref_progression"], level) + abilities.dex_mod()


func will_save() -> int:
	if has_meta("will_override"):
		return get_meta("will_override")
	return ClassDB.base_save_bonus(class_data()["will_progression"], level) + abilities.wis_mod()


## Clase de Armadura = 10 + Destreza + armadura + escudo + tamaño.
func armor_class() -> int:
	var size_mod := RaceDB.size_ac_modifier(race_data().get("size", "Medio"))
	return 10 + abilities.dex_mod() + base_armor_bonus + shield_bonus + size_mod


## Bonificador de ataque cuerpo a cuerpo: BAB + FUE (+ tamaño, omitido por simplicidad retro).
func melee_attack_bonus() -> int:
	if has_meta("attack_bonus_override"):
		return get_meta("attack_bonus_override")
	return base_attack_bonus() + abilities.str_mod()


## Bonificador de ataque a distancia: BAB + DES.
func ranged_attack_bonus() -> int:
	return base_attack_bonus() + abilities.dex_mod()


func weapon_damage_expression() -> String:
	if equipment.get("weapon") != null:
		return equipment["weapon"]["damage"]
	return "1d3"  # golpe sin arma


func melee_damage_bonus() -> int:
	return abilities.str_mod()


func sneak_attack_dice() -> int:
	return ClassDB.sneak_attack_dice(class_id, level)


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
	c.equipment = d.get("equipment", {"weapon": null, "armor": null, "shield": null})
	c.inventory = Inventory.from_dict(d.get("inventory", {}))
	c.experience = d.get("experience", 0)
	c.is_alive = c.current_hp > 0
	return c
