extends Node
## Objetos mágicos (armas, armaduras, escudos, anillos y objetos maravillosos),
## con mecánicas equivalentes a las del SRD 3.5 simplificadas a bonificadores directos.
## Un arma/armadura mágica se basa en un objeto mundano de ItemDB + una bonificación.
class_name MagicItemDB

const ITEMS := {
	# --- Armas mágicas (bonificador de mejora = ataque y daño) ---
	"daga_mas_1": {"name": "Daga +1", "type": "weapon", "base_item": "daga", "effect": {"attack_bonus": 1, "damage_bonus": 1}, "cost": 2302},
	"espada_corta_mas_1": {"name": "Espada Corta +1", "type": "weapon", "base_item": "espada_corta", "effect": {"attack_bonus": 1, "damage_bonus": 1}, "cost": 2310},
	"espada_larga_mas_1": {"name": "Espada Larga +1", "type": "weapon", "base_item": "espada_larga", "effect": {"attack_bonus": 1, "damage_bonus": 1}, "cost": 2315},
	"espada_larga_mas_2": {"name": "Espada Larga +2", "type": "weapon", "base_item": "espada_larga", "effect": {"attack_bonus": 2, "damage_bonus": 2}, "cost": 8315},
	"espada_larga_mas_3_llameante": {"name": "Espada Larga Llameante +3", "type": "weapon", "base_item": "espada_larga", "effect": {"attack_bonus": 3, "damage_bonus": 5}, "cost": 25315},
	"mazo_mas_1": {"name": "Mazo Pesado +1", "type": "weapon", "base_item": "mazo_pesado", "effect": {"attack_bonus": 1, "damage_bonus": 1}, "cost": 2312},
	"mazo_mas_2_de_la_tierra": {"name": "Mazo de la Tierra +2", "type": "weapon", "base_item": "mazo_pesado", "effect": {"attack_bonus": 2, "damage_bonus": 4}, "cost": 8312},
	"baston_mas_1": {"name": "Bastón de Mago +1", "type": "weapon", "base_item": "baston", "effect": {"attack_bonus": 1, "damage_bonus": 1, "spell_dc_bonus": 1}, "cost": 4000},
	"arco_corto_mas_1": {"name": "Arco Corto +1", "type": "weapon", "base_item": "arco_corto", "effect": {"attack_bonus": 1, "damage_bonus": 1}, "cost": 2330},
	"arco_corto_mas_2_del_viento": {"name": "Arco del Viento +2", "type": "weapon", "base_item": "arco_corto", "effect": {"attack_bonus": 3, "damage_bonus": 2}, "cost": 8330},

	# --- Armaduras y escudos mágicos (bonificador de mejora = CA) ---
	"cota_cuero_mas_1": {"name": "Cota de Cuero +1", "type": "armor", "base_item": "cota_cuero", "effect": {"ac_bonus": 1}, "cost": 1160},
	"cota_escamas_mas_1": {"name": "Cota de Escamas +1", "type": "armor", "base_item": "cota_escamas", "effect": {"ac_bonus": 1}, "cost": 1200},
	"cota_escamas_mas_2": {"name": "Cota de Escamas +2", "type": "armor", "base_item": "cota_escamas", "effect": {"ac_bonus": 2}, "cost": 4200},
	"cota_mallas_mas_1": {"name": "Cota de Mallas +1", "type": "armor", "base_item": "cota_mallas", "effect": {"ac_bonus": 1}, "cost": 1250},
	"cota_mallas_mas_2_de_piedra": {"name": "Cota de Mallas Pétrea +2", "type": "armor", "base_item": "cota_mallas", "effect": {"ac_bonus": 2, "fort_bonus": 1}, "cost": 4250},
	"escudo_pequeno_mas_1": {"name": "Escudo Pequeño +1", "type": "shield", "base_item": "escudo_pequeno", "effect": {"ac_bonus": 1}, "cost": 1159},
	"escudo_grande_mas_1": {"name": "Escudo Grande +1", "type": "shield", "base_item": "escudo_grande", "effect": {"ac_bonus": 1}, "cost": 1170},
	"escudo_grande_mas_2_del_reflejo": {"name": "Escudo del Reflejo +2", "type": "shield", "base_item": "escudo_grande", "effect": {"ac_bonus": 2, "ref_bonus": 1}, "cost": 4170},

	# --- Anillos ---
	"anillo_proteccion_1": {"name": "Anillo de Protección +1", "type": "ring", "effect": {"ac_bonus": 1}, "cost": 2000},
	"anillo_proteccion_2": {"name": "Anillo de Protección +2", "type": "ring", "effect": {"ac_bonus": 2}, "cost": 8000},
	"anillo_resistencia_1": {"name": "Anillo de Resistencia +1", "type": "ring", "effect": {"fort_bonus": 1, "ref_bonus": 1, "will_bonus": 1}, "cost": 2000},

	# --- Objetos maravillosos (amuleto/tocado, slot "amulet") ---
	"amuleto_de_la_voluntad": {"name": "Amuleto de Voluntad de Hierro", "type": "wondrous", "effect": {"will_bonus": 2}, "cost": 4000},
	"amuleto_del_guerrero": {"name": "Amuleto del Guerrero Ancestral", "type": "wondrous", "effect": {"attack_bonus": 1, "damage_bonus": 1}, "cost": 6000},
	"tocado_del_sabio": {"name": "Tocado del Sabio Elemental", "type": "wondrous", "effect": {"spell_dc_bonus": 2}, "cost": 6000},
	"amuleto_de_la_vitalidad": {"name": "Amuleto de Vitalidad", "type": "wondrous", "effect": {"fort_bonus": 2}, "cost": 4000},
	"capa_de_la_sombra": {"name": "Capa de la Sombra", "type": "wondrous", "effect": {"ref_bonus": 1, "ac_bonus": 1}, "cost": 5000},

	# --- Varitas y pergaminos (consumibles: lanzan un conjuro concreto sin gastar usos propios) ---
	"varita_proyectil_magico": {"name": "Varita de Proyectil Mágico", "type": "wand", "spell": "proyectil_magico", "charges": 20, "cost": 750},
	"varita_curar_leves": {"name": "Varita de Curar Heridas Leves", "type": "wand", "spell": "curar_heridas_leves", "charges": 20, "cost": 750},
	"pergamino_bola_de_fuego": {"name": "Pergamino de Bola de Fuego", "type": "scroll", "spell": "bola_de_fuego_menor", "charges": 1, "cost": 375},
	"pergamino_curacion": {"name": "Pergamino de Curar Heridas Moderadas", "type": "scroll", "spell": "curar_heridas_moderadas", "charges": 1, "cost": 375},

	# --- Pociones adicionales ---
	"pocion_curacion_grave": {"name": "Poción de Curación Grave", "type": "potion", "heal": "4d8+4", "cost": 700},
	"pocion_resistencia_al_fuego": {"name": "Poción de Resistencia al Fuego", "type": "potion", "heal": "0", "cost": 300},
	"elixir_de_heroismo": {"name": "Elixir de Heroísmo", "type": "potion", "heal": "0", "effect": {"attack_bonus": 2}, "cost": 1000},
}


static func get_item(id: String) -> Dictionary:
	return ITEMS.get(id, {})


static func ids() -> Array:
	return ITEMS.keys()


static func is_equippable(id: String) -> bool:
	return get_item(id).get("type", "") in ["weapon", "armor", "shield", "ring", "wondrous"]
