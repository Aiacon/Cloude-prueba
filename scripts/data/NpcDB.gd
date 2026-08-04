extends Node
## Personajes no jugadores: dan contexto narrativo y misiones. Ambientación original.
class_name NpcDB

const NPCS := {
	"alcalde_rodrigo": {
		"name": "Alcalde Rodrigo",
		"room_id": "pueblo_plaza",
		"pos": {"x": 7, "y": 3},
		"quest_id": "ecos_del_templo",
		"idle_lines": ["El pueblo confía en ustedes.", "Regresen con vida, por favor."],
	},
	"anciana_mistica": {
		"name": "Anciana Yolotl",
		"room_id": "pueblo_plaza",
		"pos": {"x": 4, "y": 5},
		"quest_id": "el_amuleto_perdido",
		"idle_lines": ["El agua recuerda todo lo que toca...", "Cuida ese amuleto cuando lo encuentres."],
	},
	"hermano_ismael": {
		"name": "Hermano Ismael",
		"room_id": "entrada",
		"pos": {"x": 5, "y": 5},
		"quest_id": "",  # se resuelve dinámicamente: siempre ofrece la siguiente misión de la cadena principal
		"idle_lines": ["Los cuatro elementos deben ser purificados en orden.", "Que tu fe te proteja allá dentro."],
	},
}


static func get_npc(id: String) -> Dictionary:
	var data: Dictionary = NPCS.get(id, {})
	if data.is_empty():
		return {}
	var result := data.duplicate(true)
	result["id"] = id
	result["pos"] = Vector2i(data["pos"]["x"], data["pos"]["y"])
	return result


## Devuelve todos los NPC ubicados en "room_id" (ya con "pos" como Vector2i).
static func npcs_in_room(room_id: String) -> Array:
	var result: Array = []
	for id in NPCS:
		if NPCS[id]["room_id"] == room_id:
			result.append(get_npc(id))
	return result
