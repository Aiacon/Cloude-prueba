extends Node
## Bestiario original con mecánicas inspiradas en el SRD 3.5 (elementales y cultistas).
## Contenido de ambientación propio - no reproduce texto ni mapas de módulos con copyright.
## Cada entrada incluye una tabla de botín ("loot_table") con probabilidad de caída
## por objeto, además del oro y la experiencia otorgados al derrotarlo.
class_name MonsterDB

const MONSTERS := {
	"cultista_fuego": {
		"name": "Cultista de la Llama",
		"element": "fuego",
		"hit_dice": "2d8+2",
		"armor_class": 13,
		"attack_bonus": 2,
		"damage": "1d6+1",
		"fort": 3, "ref": 0, "will": 1,
		"xp_reward": 50,
		"loot_gold": "1d10",
		"loot_table": [
			{"item_id": "daga", "source": "mundane", "chance": 0.25},
			{"item_id": "pocion_curacion_leve", "source": "mundane", "chance": 0.2},
		],
		"visual": {"shape": "humanoid", "primary": Color(0.55, 0.42, 0.36), "accent": Color(0.75, 0.22, 0.12), "accessory": "dagger", "hood": true},
	},
	"guardian_agua": {
		"name": "Guardián de las Mareas",
		"element": "agua",
		"hit_dice": "3d8+3",
		"armor_class": 14,
		"attack_bonus": 4,
		"damage": "1d8+2",
		"fort": 4, "ref": 1, "will": 1,
		"xp_reward": 75,
		"loot_gold": "2d10",
		"loot_table": [
			{"item_id": "cota_cuero", "source": "mundane", "chance": 0.2},
			{"item_id": "pocion_curacion_leve", "source": "mundane", "chance": 0.25},
		],
		"visual": {"shape": "humanoid", "primary": Color(0.6, 0.68, 0.7), "accent": Color(0.15, 0.35, 0.55), "accessory": "trident", "hood": false},
	},
	"acolito_aire": {
		"name": "Acólito del Vendaval",
		"element": "aire",
		"hit_dice": "2d6+2",
		"armor_class": 15,
		"attack_bonus": 3,
		"damage": "1d4+1",
		"fort": 2, "ref": 3, "will": 2,
		"xp_reward": 50,
		"loot_gold": "1d10",
		"loot_table": [
			{"item_id": "arco_corto", "source": "mundane", "chance": 0.15},
			{"item_id": "pocion_curacion_leve", "source": "mundane", "chance": 0.2},
		],
		"visual": {"shape": "humanoid", "primary": Color(0.75, 0.78, 0.72), "accent": Color(0.55, 0.68, 0.62), "accessory": "bow", "hood": true},
	},
	"centinela_tierra": {
		"name": "Centinela de Granito",
		"element": "tierra",
		"hit_dice": "4d8+8",
		"armor_class": 16,
		"attack_bonus": 5,
		"damage": "1d10+3",
		"fort": 6, "ref": 0, "will": 1,
		"xp_reward": 100,
		"loot_gold": "2d12",
		"loot_table": [
			{"item_id": "escudo_grande", "source": "mundane", "chance": 0.2},
			{"item_id": "anillo_resistencia_1", "source": "magic", "chance": 0.05},
		],
		"visual": {"shape": "golem", "primary": Color(0.42, 0.38, 0.32), "accent": Color(0.75, 0.6, 0.25), "height": 1.15, "width": 1.2},
	},
	"elemental_fuego_menor": {
		"name": "Elemental de Fuego Menor",
		"element": "fuego",
		"hit_dice": "3d8+6",
		"armor_class": 15,
		"attack_bonus": 5,
		"damage": "1d4",
		"special": "Contacto ígneo: +1d4 daño de fuego adicional",
		"fort": 3, "ref": 4, "will": 1,
		"xp_reward": 90,
		"loot_gold": "0",
		"loot_table": [
			{"item_id": "pergamino_bola_de_fuego", "source": "magic", "chance": 0.1},
		],
		"visual": {"shape": "flame", "primary": Color(1.0, 0.65, 0.15), "accent": Color(0.75, 0.15, 0.05)},
	},
	"elemental_agua_menor": {
		"name": "Elemental de Agua Menor",
		"element": "agua",
		"hit_dice": "3d8+6",
		"armor_class": 15,
		"attack_bonus": 5,
		"damage": "1d6",
		"fort": 3, "ref": 4, "will": 1,
		"xp_reward": 90,
		"loot_gold": "0",
		"loot_table": [
			{"item_id": "pergamino_curacion", "source": "magic", "chance": 0.1},
		],
		"visual": {"shape": "droplet", "primary": Color(0.2, 0.5, 0.85), "accent": Color(0.7, 0.87, 1.0)},
	},
	"elemental_aire_menor": {
		"name": "Elemental de Aire Menor",
		"element": "aire",
		"hit_dice": "3d8+6",
		"armor_class": 17,
		"attack_bonus": 6,
		"damage": "1d4",
		"fort": 3, "ref": 6, "will": 1,
		"xp_reward": 90,
		"loot_gold": "0",
		"loot_table": [
			{"item_id": "anillo_proteccion_1", "source": "magic", "chance": 0.05},
		],
		"visual": {"shape": "swirl", "primary": Color(0.75, 0.95, 0.92)},
	},
	"elemental_tierra_menor": {
		"name": "Elemental de Tierra Menor",
		"element": "tierra",
		"hit_dice": "3d8+9",
		"armor_class": 16,
		"attack_bonus": 6,
		"damage": "1d8",
		"fort": 5, "ref": 0, "will": 1,
		"xp_reward": 90,
		"loot_gold": "0",
		"loot_table": [
			{"item_id": "amuleto_de_la_vitalidad", "source": "magic", "chance": 0.05},
		],
		"visual": {"shape": "rock", "primary": Color(0.5, 0.42, 0.32), "accent": Color(0.32, 0.55, 0.3)},
	},
	"sumo_sacerdote_elemental": {
		"name": "Sumo Sacerdote del Nexo Elemental",
		"element": "todos",
		"hit_dice": "8d8+16",
		"armor_class": 19,
		"attack_bonus": 9,
		"damage": "1d8+3",
		"special": "Invoca un elemental menor aliado al 50% de sus PG",
		"fort": 8, "ref": 4, "will": 8,
		"xp_reward": 400,
		"loot_gold": "5d20",
		"is_boss": true,
		"loot_table": [
			{"item_id": "espada_larga_mas_3_llameante", "source": "magic", "chance": 1.0},
			{"item_id": "tocado_del_sabio", "source": "magic", "chance": 0.5},
		],
		"visual": {"shape": "humanoid", "primary": Color(0.65, 0.55, 0.6), "accent": Color(0.35, 0.12, 0.42), "accessory": "staff", "hood": true, "halo": true, "height": 1.2, "width": 1.1},
	},
}


static func get_monster(id: String) -> Dictionary:
	return MONSTERS.get(id, {})


## Crea un Character (PNJ) a partir de una entrada del bestiario.
static func instantiate(id: String) -> Character:
	var data := get_monster(id)
	if data.is_empty():
		return null
	var c := Character.new()
	c.character_name = data["name"]
	c.race_id = "human"
	c.class_id = "fighter"
	c.abilities = AbilityScores.new(10, 10, 10, 10, 10, 10)  # el daño/ataque ya viene fijado por el bestiario, sin duplicar bonificadores
	c.max_hp = max(1, Dice.roll_expression(data["hit_dice"]))
	c.current_hp = c.max_hp
	c.base_armor_bonus = data["armor_class"] - 10 - c.abilities.dex_mod()
	c.inventory = Inventory.new()
	c.inventory.add_gold(Dice.roll_expression(data.get("loot_gold", "0")))
	c.equipment["weapon"] = {"name": "ataque natural", "damage": data["damage"], "hands": "melee"}
	c.set_meta("monster_id", id)
	c.set_meta("attack_bonus_override", data["attack_bonus"])
	c.set_meta("fort_override", data["fort"])
	c.set_meta("ref_override", data["ref"])
	c.set_meta("will_override", data["will"])
	c.set_meta("xp_reward", data["xp_reward"])
	c.set_meta("element", data.get("element", "ninguno"))
	c.set_meta("is_boss", data.get("is_boss", false))
	return c


## Tira la tabla de botín de un monstruo y devuelve los objetos obtenidos como
## [{"name":String, "item_id":String, "source":"mundane"|"magic"}, ...]
static func roll_loot(id: String) -> Array:
	var data := get_monster(id)
	var drops: Array = []
	for entry in data.get("loot_table", []):
		if randf() <= entry["chance"]:
			var item_name: String
			if entry["source"] == "magic":
				item_name = MagicItemDB.get_item(entry["item_id"]).get("name", entry["item_id"])
			else:
				item_name = ItemDB.get_item(entry["item_id"]).get("name", entry["item_id"])
			drops.append({"name": item_name, "item_id": entry["item_id"], "source": entry["source"]})
	return drops
