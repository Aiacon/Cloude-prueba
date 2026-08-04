extends Node2D
## Construye visualmente una sala del templo usando bloques de color (estética retro,
## sin dependencias de assets gráficos externos) a partir de LevelData.
class_name DungeonBuilder

const TILE_SIZE := 16

const COLOR_WALL := Color(0.12, 0.12, 0.16)
const COLOR_FLOOR := Color(0.24, 0.22, 0.2)
const COLOR_DOOR := Color(0.55, 0.42, 0.2)
const COLOR_PORTAL := Color(0.75, 0.2, 0.85)
const COLOR_ENCOUNTER := Color(0.7, 0.15, 0.15)
const COLOR_PICKUP := Color(0.95, 0.85, 0.2)
const COLOR_NPC := Color(0.3, 0.75, 0.9)

const ELEMENT_TINTS := {
	"fuego": Color(0.35, 0.12, 0.08),
	"agua": Color(0.08, 0.18, 0.35),
	"aire": Color(0.2, 0.3, 0.32),
	"tierra": Color(0.22, 0.18, 0.08),
	"todos": Color(0.25, 0.1, 0.3),
	"ninguno": COLOR_FLOOR,
	"pueblo": Color(0.16, 0.28, 0.14),
}

var room_id: String = ""
var room_data: Dictionary = {}
var walkable: Dictionary = {}       # Vector2i -> true
var doors_by_pos: Dictionary = {}   # Vector2i -> door dict
var portals_by_pos: Dictionary = {}
var encounters_by_pos: Dictionary = {}
var pickups_by_pos: Dictionary = {}
var npcs_by_pos: Dictionary = {}

@onready var tiles_container: Node2D = Node2D.new()


func _ready() -> void:
	add_child(tiles_container)


func load_room(target_room_id: String, spawn_pos: Vector2i) -> Vector2i:
	room_id = target_room_id
	room_data = LevelData.get_room(room_id)
	GameManager.current_level_id = room_id
	GameManager.visited_rooms[room_id] = true

	for child in tiles_container.get_children():
		child.queue_free()
	walkable.clear()
	doors_by_pos.clear()
	portals_by_pos.clear()
	encounters_by_pos.clear()
	pickups_by_pos.clear()
	npcs_by_pos.clear()

	_build_grid()
	_build_doors()
	_build_portals()
	_build_encounters()
	_build_pickups()
	_build_npcs()

	return spawn_pos


func _dict_to_v2i(d: Dictionary) -> Vector2i:
	return Vector2i(d.get("x", 0), d.get("y", 0))


func _place_tile(pos: Vector2i, color: Color) -> void:
	var rect := ColorRect.new()
	rect.size = Vector2(TILE_SIZE - 1, TILE_SIZE - 1)
	rect.position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
	rect.color = color
	tiles_container.add_child(rect)


func _build_grid() -> void:
	var width: int = room_data["width"]
	var height: int = room_data["height"]
	var element: String = room_data.get("element", "ninguno")
	var floor_color: Color = ELEMENT_TINTS.get(element, COLOR_FLOOR)

	var door_positions := {}
	for door in room_data.get("doors", []):
		door_positions[_dict_to_v2i(door["pos"])] = true
	for portal in room_data.get("portals", []):
		door_positions[_dict_to_v2i(portal["pos"])] = true

	for x in range(width):
		for y in range(height):
			var pos := Vector2i(x, y)
			var is_border := x == 0 or y == 0 or x == width - 1 or y == height - 1
			if is_border and not door_positions.has(pos):
				_place_tile(pos, COLOR_WALL)
			else:
				_place_tile(pos, floor_color)
				walkable[pos] = true


func _build_doors() -> void:
	for door in room_data.get("doors", []):
		var pos := _dict_to_v2i(door["pos"])
		_place_tile(pos, COLOR_DOOR)
		walkable[pos] = true
		doors_by_pos[pos] = door


func _build_portals() -> void:
	for portal in room_data.get("portals", []):
		var pos := _dict_to_v2i(portal["pos"])
		_place_tile(pos, COLOR_PORTAL)
		walkable[pos] = true
		portals_by_pos[pos] = portal


func _build_encounters() -> void:
	for enc in room_data.get("encounters", []):
		var key := "%s:%s" % [room_id, enc["id"]]
		if GameManager.cleared_encounters.get(key, false):
			continue
		var pos := _dict_to_v2i(enc["pos"])
		_place_tile(pos, COLOR_ENCOUNTER)
		encounters_by_pos[pos] = enc


func _build_pickups() -> void:
	for pickup in room_data.get("pickups", []):
		var key := "%s:%s" % [room_id, pickup["id"]]
		if GameManager.collected_pickups.get(key, false):
			continue
		var requires: String = pickup.get("requires_cleared", "")
		if requires != "":
			var req_key := "%s:%s" % [room_id, requires]
			if not GameManager.cleared_encounters.get(req_key, false):
				continue
		var pos := _dict_to_v2i(pickup["pos"])
		_place_tile(pos, COLOR_PICKUP)
		pickups_by_pos[pos] = pickup


## Los NPC ocupan una casilla sólida (no se puede caminar sobre ellos, se les habla
## desde una casilla adyacente).
func _build_npcs() -> void:
	for npc in NpcDB.npcs_in_room(room_id):
		var pos: Vector2i = npc["pos"]
		_place_tile(pos, COLOR_NPC)
		walkable.erase(pos)
		npcs_by_pos[pos] = npc


func is_walkable(pos: Vector2i) -> bool:
	return walkable.has(pos)


## Devuelve el NPC adyacente (arriba/abajo/izquierda/derecha) a "pos", o un diccionario
## vacío si no hay ninguno.
func adjacent_npc(pos: Vector2i) -> Dictionary:
	for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if npcs_by_pos.has(pos + dir):
			return npcs_by_pos[pos + dir]
	return {}
