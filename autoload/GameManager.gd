extends Node
## Estado global: grupo de personajes, progreso en el templo, transición de escenas.

var party: Array = []          # Array[Character]
var active_character_index: int = 0
var current_level_id: String = "pueblo_plaza"
var visited_rooms: Dictionary = {}   # room_id -> bool
var quest_flags: Dictionary = {}     # flag_name -> bool/valor
var pending_encounter: Dictionary = {}  # se llena antes de cambiar a Combat.tscn
var cleared_encounters: Dictionary = {}   # "room_id:encounter_id" -> true
var collected_pickups: Dictionary = {}    # "room_id:pickup_id" -> true
var keys_collected: int = 0
var player_return_pos: Vector2i = Vector2i(-1, -1)   # posición a la que vuelve el jugador tras un combate (-1,-1 = sin definir)
var quest_states: Dictionary = {}   # quest_id -> "active" | "completed"

const SCENE_MAIN_MENU := "res://scenes/MainMenu.tscn"
const SCENE_CHAR_CREATION := "res://scenes/CharacterCreation.tscn"
const SCENE_DUNGEON := "res://scenes/Dungeon.tscn"
const SCENE_COMBAT := "res://scenes/Combat.tscn"


func get_active_character():
	if party.is_empty():
		return null
	return party[active_character_index]


func is_party_alive() -> bool:
	for member in party:
		if member.current_hp > 0:
			return true
	return false


func start_encounter(monster_ids: Array, room_id: String, encounter_id: String, return_pos: Vector2i) -> void:
	pending_encounter = {
		"monster_ids": monster_ids,
		"room_id": room_id,
		"encounter_id": encounter_id,
	}
	player_return_pos = return_pos
	get_tree().change_scene_to_file(SCENE_COMBAT)


func return_to_dungeon() -> void:
	get_tree().change_scene_to_file(SCENE_DUNGEON)


func new_game() -> void:
	party.clear()
	active_character_index = 0
	current_level_id = "pueblo_plaza"
	visited_rooms.clear()
	quest_flags.clear()
	cleared_encounters.clear()
	collected_pickups.clear()
	keys_collected = 0
	player_return_pos = Vector2i(-1, -1)
	quest_states.clear()
	get_tree().change_scene_to_file(SCENE_CHAR_CREATION)


func begin_adventure() -> void:
	get_tree().change_scene_to_file(SCENE_DUNGEON)


## Descanso completo del grupo: restaura PG y usos de conjuro de todos los miembros.
func rest_party() -> void:
	for member in party:
		member.rest()
	EventBus.game_message.emit("El grupo descansa y recupera fuerzas.")


func accept_quest(quest_id: String) -> void:
	quest_states[quest_id] = "active"


func complete_quest(quest_id: String) -> void:
	var quest := QuestDB.get_quest(quest_id)
	if quest.is_empty():
		return
	quest_states[quest_id] = "completed"
	var leader: Character = party[0]
	leader.inventory.add_gold(quest.get("reward_gold", 0))
	var xp: int = quest.get("reward_xp", 0)
	if xp > 0:
		for member in party:
			if member.current_hp <= 0:
				continue
			member.experience += xp
			while member.level < ProgressionDB.MAX_LEVEL and member.experience >= ProgressionDB.xp_for_level(member.level + 1):
				member.level_up()
