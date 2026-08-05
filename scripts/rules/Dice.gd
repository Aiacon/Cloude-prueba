extends Node
## Utilidad de tiradas de dados estilo D&D (dN, "XdY+Z").
class_name Dice

static var _rng := RandomNumberGenerator.new()
static var _seeded := false


static func _ensure_seed() -> void:
	if not _seeded:
		_rng.randomize()
		_seeded = true


## Tira un solo dado de "sides" caras.
static func roll(sides: int) -> int:
	_ensure_seed()
	return _rng.randi_range(1, sides)


## Tira "count" dados de "sides" caras y suma el resultado.
static func roll_multiple(count: int, sides: int) -> int:
	var total := 0
	for i in range(count):
		total += roll(sides)
	return total


## Tira una expresión estilo "2d6+3", "1d20-1", "1d8".
static func roll_expression(expr: String) -> int:
	var clean := expr.strip_edges().to_lower().replace(" ", "")
	var sign := 1
	var modifier := 0
	var dice_part := clean

	if "+" in clean:
		var parts := clean.split("+")
		dice_part = parts[0]
		modifier = int(parts[1])
	elif clean.count("-") == 1 and not clean.begins_with("-"):
		var parts := clean.split("-")
		dice_part = parts[0]
		modifier = -int(parts[1])

	if "d" in dice_part:
		var dparts := dice_part.split("d")
		var count := 1 if dparts[0] == "" else int(dparts[0])
		var sides := int(dparts[1])
		return roll_multiple(count, sides) + modifier
	else:
		return int(dice_part) + modifier


## d20 estándar, con posibilidad de ventaja/desventaja (no-SRD, opcional retro QoL).
static func d20() -> int:
	return roll(20)
