extends Node2D
## Controlador de movimiento por rejilla (estilo RPG retro de 4 direcciones).
class_name Player

signal tile_entered(pos: Vector2i)

const TILE_SIZE := 16
const MOVE_DURATION := 0.14

var dungeon: DungeonBuilder = null
var grid_pos: Vector2i = Vector2i.ZERO
var moving: bool = false
var move_elapsed: float = 0.0
var start_pixel: Vector2 = Vector2.ZERO
var target_pixel: Vector2 = Vector2.ZERO
var pending_direction: Vector2i = Vector2i.ZERO
var input_locked: bool = false   # true mientras hay un diálogo abierto

var visual: ColorRect


func _ready() -> void:
	visual = ColorRect.new()
	visual.size = Vector2(TILE_SIZE - 4, TILE_SIZE - 4)
	visual.position = Vector2(2, 2)
	visual.color = Color(0.9, 0.9, 0.95)
	add_child(visual)


func place_at(pos: Vector2i) -> void:
	grid_pos = pos
	position = Vector2(pos.x * TILE_SIZE, pos.y * TILE_SIZE)
	moving = false


func set_input_direction(dir: Vector2i) -> void:
	pending_direction = dir


func _process(delta: float) -> void:
	if input_locked:
		return
	if moving:
		move_elapsed += delta
		var t: float = clamp(move_elapsed / MOVE_DURATION, 0.0, 1.0)
		position = start_pixel.lerp(target_pixel, t)
		if t >= 1.0:
			moving = false
			position = target_pixel
			tile_entered.emit(grid_pos)
		return

	var dir := pending_direction
	if dir == Vector2i.ZERO:
		dir = _read_keyboard_direction()

	if dir != Vector2i.ZERO and dungeon != null:
		var target := grid_pos + dir
		if dungeon.is_walkable(target):
			grid_pos = target
			start_pixel = position
			target_pixel = Vector2(target.x * TILE_SIZE, target.y * TILE_SIZE)
			move_elapsed = 0.0
			moving = true


func _read_keyboard_direction() -> Vector2i:
	if Input.is_action_pressed("ui_right"):
		return Vector2i.RIGHT
	if Input.is_action_pressed("ui_left"):
		return Vector2i.LEFT
	if Input.is_action_pressed("ui_down"):
		return Vector2i.DOWN
	if Input.is_action_pressed("ui_up"):
		return Vector2i.UP
	return Vector2i.ZERO
