extends Node
## Guardado/carga de partida en formato JSON dentro de user:// (compatible con Android).
class_name SaveSystem

const SAVE_PATH := "user://templo_elemental_save.json"


static func save_game() -> bool:
	var data := {
		"party": GameManager.party.map(func(c): return c.to_dict()),
		"active_character_index": GameManager.active_character_index,
		"current_level_id": GameManager.current_level_id,
		"visited_rooms": GameManager.visited_rooms,
		"quest_flags": GameManager.quest_flags,
		"cleared_encounters": GameManager.cleared_encounters,
		"collected_pickups": GameManager.collected_pickups,
		"keys_collected": GameManager.keys_collected,
		"quest_states": GameManager.quest_states,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo abrir el archivo de guardado para escritura.")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


static func load_game() -> bool:
	if not has_save():
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(text)
	if parse_result != OK:
		push_error("Guardado corrupto: %s" % json.get_error_message())
		return false

	var data: Dictionary = json.data
	GameManager.party = []
	for c_dict in data.get("party", []):
		GameManager.party.append(Character.from_dict(c_dict))
	GameManager.active_character_index = data.get("active_character_index", 0)
	GameManager.current_level_id = data.get("current_level_id", "entrada")
	GameManager.visited_rooms = data.get("visited_rooms", {})
	GameManager.quest_flags = data.get("quest_flags", {})
	GameManager.cleared_encounters = data.get("cleared_encounters", {})
	GameManager.collected_pickups = data.get("collected_pickups", {})
	GameManager.keys_collected = data.get("keys_collected", 0)
	GameManager.quest_states = data.get("quest_states", {})
	return true


static func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
