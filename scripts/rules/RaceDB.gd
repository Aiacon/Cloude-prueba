extends Node
## Base de datos de razas jugables (contenido de reglas basado en el SRD 3.5 / OGL).
class_name RaceDB

const RACES := {
	"human": {
		"name": "Humano",
		"ability_adjustments": {},
		"size": "Medio",
		"speed": 9,  # casillas de 1.5m ("30 pies" -> 6 casillas de 1.5m en SRD; aquí usamos 9 tiles retro)
		"bonus_feat": true,
		"skill_points_bonus": 1,
		"traits": ["Un dote adicional a nivel 1", "+4 puntos de habilidad extra a nivel 1, +1/nivel"],
		"favored_class": "cualquiera",
	},
	"elf": {
		"name": "Elfo",
		"ability_adjustments": {"dex": 2, "con": -2},
		"size": "Medio",
		"speed": 9,
		"bonus_feat": false,
		"skill_points_bonus": 0,
		"traits": ["Visión en penumbra", "Inmune a sueño mágico", "+2 a salvación vs. encantamientos", "Competencia con armas élficas"],
		"favored_class": "Mago",
	},
	"dwarf": {
		"name": "Enano",
		"ability_adjustments": {"con": 2, "cha": -2},
		"size": "Medio",
		"speed": 6,
		"bonus_feat": false,
		"skill_points_bonus": 0,
		"traits": ["Visión en la oscuridad 18m", "Conocimiento de la piedra", "+2 a salvaciones vs. veneno", "+1 a ataque vs. orcos y trasgos"],
		"favored_class": "Guerrero",
	},
	"halfling": {
		"name": "Mediano",
		"ability_adjustments": {"dex": 2, "str": -2},
		"size": "Pequeño",
		"speed": 6,
		"bonus_feat": false,
		"skill_points_bonus": 0,
		"traits": ["+1 CA y +1 a ataque por tamaño pequeño", "+2 a Moverse Sigilosamente", "+1 a todas las salvaciones"],
		"favored_class": "Pícaro",
	},
}


static func get_race(id: String) -> Dictionary:
	return RACES.get(id, RACES["human"])


static func ids() -> Array:
	return RACES.keys()


static func size_ac_modifier(size: String) -> int:
	match size:
		"Pequeño": return 1
		"Grande": return -1
		_: return 0
