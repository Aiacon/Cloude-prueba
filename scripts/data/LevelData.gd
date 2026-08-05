extends Node
## Diseño original del "Templo Elemental": vestíbulo central + 4 alas + cámara final.
## Contenido de ambientación propio, no reproduce mapas ni texto de módulos con copyright.
class_name LevelData

const ROOMS := {
	"entrada": {
		"name": "Vestíbulo del Templo",
		"width": 13, "height": 11,
		"element": "ninguno",
		"start_pos": {"x": 6, "y": 5},
		"doors": [
			{"pos": {"x": 6, "y": 0}, "target_room": "ala_aire", "target_pos": {"x": 4, "y": 5}},
			{"pos": {"x": 6, "y": 10}, "target_room": "ala_tierra", "target_pos": {"x": 4, "y": 1}},
			{"pos": {"x": 0, "y": 5}, "target_room": "ala_agua", "target_pos": {"x": 7, "y": 3}},
			{"pos": {"x": 12, "y": 5}, "target_room": "ala_fuego", "target_pos": {"x": 1, "y": 3}},
			{"pos": {"x": 2, "y": 10}, "target_room": "pueblo_plaza", "target_pos": {"x": 7, "y": 7}},
		],
		"portals": [
			{"pos": {"x": 6, "y": 3}, "target_room": "camara_final", "target_pos": {"x": 4, "y": 7}, "required_keys": 4},
		],
		"encounters": [],
		"pickups": [],
	},
	"pueblo_plaza": {
		"name": "Plaza del Pueblo",
		"width": 15, "height": 9,
		"element": "pueblo",
		"start_pos": {"x": 7, "y": 4},
		"doors": [
			{"pos": {"x": 7, "y": 8}, "target_room": "entrada", "target_pos": {"x": 2, "y": 9}},
		],
		"portals": [],
		"encounters": [],
		"pickups": [],
	},
	"ala_fuego": {
		"name": "Ala del Fuego",
		"width": 9, "height": 7,
		"element": "fuego",
		"start_pos": {"x": 1, "y": 3},
		"doors": [
			{"pos": {"x": 0, "y": 3}, "target_room": "entrada", "target_pos": {"x": 11, "y": 5}},
		],
		"portals": [],
		"encounters": [
			{"id": "fuego_1", "pos": {"x": 3, "y": 3}, "monsters": ["cultista_fuego", "cultista_fuego"]},
			{"id": "fuego_2", "pos": {"x": 6, "y": 2}, "monsters": ["elemental_fuego_menor"]},
		],
		"pickups": [
			{"id": "fuego_key", "pos": {"x": 7, "y": 4}, "item": "llave_ala_fuego", "quantity": 1},
			{"id": "fuego_potion", "pos": {"x": 2, "y": 1}, "item": "pocion_curacion_leve", "quantity": 1},
		],
	},
	"ala_agua": {
		"name": "Ala del Agua",
		"width": 9, "height": 7,
		"element": "agua",
		"start_pos": {"x": 7, "y": 3},
		"doors": [
			{"pos": {"x": 8, "y": 3}, "target_room": "entrada", "target_pos": {"x": 1, "y": 5}},
		],
		"portals": [],
		"encounters": [
			{"id": "agua_1", "pos": {"x": 5, "y": 3}, "monsters": ["guardian_agua"]},
			{"id": "agua_2", "pos": {"x": 2, "y": 2}, "monsters": ["elemental_agua_menor"]},
		],
		"pickups": [
			{"id": "agua_key", "pos": {"x": 1, "y": 4}, "item": "llave_ala_agua", "quantity": 1},
			{"id": "agua_potion", "pos": {"x": 6, "y": 1}, "item": "pocion_curacion_leve", "quantity": 1},
		],
	},
	"ala_aire": {
		"name": "Ala del Aire",
		"width": 9, "height": 7,
		"element": "aire",
		"start_pos": {"x": 4, "y": 5},
		"doors": [
			{"pos": {"x": 4, "y": 6}, "target_room": "entrada", "target_pos": {"x": 6, "y": 9}},
		],
		"portals": [],
		"encounters": [
			{"id": "aire_1", "pos": {"x": 4, "y": 3}, "monsters": ["acolito_aire", "acolito_aire"]},
			{"id": "aire_2", "pos": {"x": 2, "y": 1}, "monsters": ["elemental_aire_menor"]},
		],
		"pickups": [
			{"id": "aire_key", "pos": {"x": 7, "y": 1}, "item": "llave_ala_aire", "quantity": 1},
			{"id": "aire_potion", "pos": {"x": 1, "y": 4}, "item": "pocion_curacion_leve", "quantity": 1},
		],
	},
	"ala_tierra": {
		"name": "Ala de la Tierra",
		"width": 9, "height": 7,
		"element": "tierra",
		"start_pos": {"x": 4, "y": 1},
		"doors": [
			{"pos": {"x": 4, "y": 0}, "target_room": "entrada", "target_pos": {"x": 6, "y": 9}},
		],
		"portals": [],
		"encounters": [
			{"id": "tierra_1", "pos": {"x": 4, "y": 3}, "monsters": ["centinela_tierra"]},
			{"id": "tierra_2", "pos": {"x": 6, "y": 5}, "monsters": ["elemental_tierra_menor"]},
		],
		"pickups": [
			{"id": "tierra_key", "pos": {"x": 2, "y": 5}, "item": "llave_ala_tierra", "quantity": 1},
			{"id": "tierra_potion", "pos": {"x": 6, "y": 1}, "item": "pocion_curacion_leve", "quantity": 1},
		],
	},
	"camara_final": {
		"name": "Cámara del Nexo Elemental",
		"width": 9, "height": 9,
		"element": "todos",
		"start_pos": {"x": 4, "y": 7},
		"doors": [
			{"pos": {"x": 4, "y": 8}, "target_room": "entrada", "target_pos": {"x": 6, "y": 4}},
		],
		"portals": [],
		"encounters": [
			{"id": "boss", "pos": {"x": 4, "y": 3}, "monsters": ["sumo_sacerdote_elemental"], "is_boss": true},
		],
		"pickups": [
			{"id": "amuleto", "pos": {"x": 4, "y": 2}, "item": "amuleto_del_nexo", "quantity": 1, "requires_cleared": "boss"},
		],
	},
}


static func get_room(room_id: String) -> Dictionary:
	return ROOMS.get(room_id, ROOMS["entrada"])


static func ids() -> Array:
	return ROOMS.keys()
