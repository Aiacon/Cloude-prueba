extends RefCounted
## Las seis características D&D 3.5: Fuerza, Destreza, Constitución, Inteligencia, Sabiduría, Carisma.
class_name AbilityScores

var strength: int = 10
var dexterity: int = 10
var constitution: int = 10
var intelligence: int = 10
var wisdom: int = 10
var charisma: int = 10


func _init(str_ := 10, dex_ := 10, con_ := 10, int_ := 10, wis_ := 10, cha_ := 10) -> void:
	strength = str_
	dexterity = dex_
	constitution = con_
	intelligence = int_
	wisdom = wis_
	charisma = cha_


static func modifier(score: int) -> int:
	return int(floor(float(score - 10) / 2.0))


func str_mod() -> int: return modifier(strength)
func dex_mod() -> int: return modifier(dexterity)
func con_mod() -> int: return modifier(constitution)
func int_mod() -> int: return modifier(intelligence)
func wis_mod() -> int: return modifier(wisdom)
func cha_mod() -> int: return modifier(charisma)


## Método clásico de generación 3.5: 4d6, se descarta el menor, x6.
static func roll_4d6_drop_lowest() -> int:
	var rolls: Array = []
	for i in range(4):
		rolls.append(Dice.roll(6))
	rolls.sort()
	rolls.pop_front()
	var total := 0
	for r in rolls:
		total += r
	return total


static func roll_full_array() -> AbilityScores:
	return AbilityScores.new(
		roll_4d6_drop_lowest(),
		roll_4d6_drop_lowest(),
		roll_4d6_drop_lowest(),
		roll_4d6_drop_lowest(),
		roll_4d6_drop_lowest(),
		roll_4d6_drop_lowest()
	)


func apply_racial_adjustments(adjustments: Dictionary) -> void:
	strength += adjustments.get("str", 0)
	dexterity += adjustments.get("dex", 0)
	constitution += adjustments.get("con", 0)
	intelligence += adjustments.get("int", 0)
	wisdom += adjustments.get("wis", 0)
	charisma += adjustments.get("cha", 0)


func to_dict() -> Dictionary:
	return {
		"str": strength, "dex": dexterity, "con": constitution,
		"int": intelligence, "wis": wisdom, "cha": charisma,
	}


static func from_dict(d: Dictionary) -> AbilityScores:
	return AbilityScores.new(
		d.get("str", 10), d.get("dex", 10), d.get("con", 10),
		d.get("int", 10), d.get("wis", 10), d.get("cha", 10)
	)
