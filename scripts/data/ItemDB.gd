extends Node
## Objetos: armas, armaduras, escudos y consumibles (equilibrados sobre el SRD 3.5).
class_name ItemDB

const ITEMS := {
	"daga": {"name": "Daga", "type": "weapon", "damage": "1d4", "cost": 2, "hands": "melee"},
	"espada_corta": {"name": "Espada Corta", "type": "weapon", "damage": "1d6", "cost": 10, "hands": "melee"},
	"espada_larga": {"name": "Espada Larga", "type": "weapon", "damage": "1d8", "cost": 15, "hands": "melee"},
	"mazo_pesado": {"name": "Mazo Pesado", "type": "weapon", "damage": "1d8", "cost": 12, "hands": "melee"},
	"baston": {"name": "Bastón de Mago", "type": "weapon", "damage": "1d6", "cost": 5, "hands": "melee"},
	"arco_corto": {"name": "Arco Corto", "type": "weapon", "damage": "1d6", "cost": 30, "hands": "ranged"},

	"armadura_acolchada": {"name": "Armadura Acolchada", "type": "armor", "ac_bonus": 1, "cost": 5},
	"cota_cuero": {"name": "Cota de Cuero", "type": "armor", "ac_bonus": 2, "cost": 10},
	"cota_escamas": {"name": "Cota de Escamas", "type": "armor", "ac_bonus": 4, "cost": 50},
	"cota_mallas": {"name": "Cota de Mallas", "type": "armor", "ac_bonus": 5, "cost": 100},

	"escudo_pequeno": {"name": "Escudo Pequeño", "type": "shield", "ac_bonus": 1, "cost": 9},
	"escudo_grande": {"name": "Escudo Grande", "type": "shield", "ac_bonus": 2, "cost": 20},

	"pocion_curacion_leve": {"name": "Poción de Curación Leve", "type": "potion", "heal": "1d8+1", "cost": 50},
	"pocion_curacion_moderada": {"name": "Poción de Curación Moderada", "type": "potion", "heal": "2d8+3", "cost": 150},
	"antidoto": {"name": "Antídoto", "type": "potion", "heal": "0", "cures": "veneno", "cost": 50},

	"llave_ala_fuego": {"name": "Llave del Ala de Fuego", "type": "key", "cost": 0},
	"llave_ala_agua": {"name": "Llave del Ala de Agua", "type": "key", "cost": 0},
	"llave_ala_aire": {"name": "Llave del Ala de Aire", "type": "key", "cost": 0},
	"llave_ala_tierra": {"name": "Llave del Ala de Tierra", "type": "key", "cost": 0},
	"amuleto_del_nexo": {"name": "Amuleto del Nexo Elemental", "type": "quest", "cost": 0},
}


static func get_item(id: String) -> Dictionary:
	return ITEMS.get(id, {})


static func is_weapon(id: String) -> bool:
	return get_item(id).get("type", "") == "weapon"


static func is_armor(id: String) -> bool:
	return get_item(id).get("type", "") == "armor"


static func is_shield(id: String) -> bool:
	return get_item(id).get("type", "") == "shield"


static func is_potion(id: String) -> bool:
	return get_item(id).get("type", "") == "potion"
