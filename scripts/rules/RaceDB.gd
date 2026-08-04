extends Node
## Base de datos de razas jugables: las 7 razas núcleo del Manual del Jugador
## (contenido de reglas basado en el SRD 3.5 / OGL).
class_name RaceDB

const RACES := {
	"human": {
		"name": "Humano",
		"ability_adjustments": {},
		"size": "Medio",
		"speed": 9,  # casillas de 1.5m ("30 pies" -> 6 casillas de 1.5m en SRD; aquí usamos 9 tiles retro)
		"bonus_feat": true,
		"skill_points_bonus": 1,
		"effects": {},
		"traits": ["Una dote adicional a nivel 1", "+4 puntos de habilidad extra a nivel 1, +1/nivel"],
		"favored_class": "Cualquiera",
	},
	"elf": {
		"name": "Elfo",
		"ability_adjustments": {"dex": 2, "con": -2},
		"size": "Medio",
		"speed": 9,
		"bonus_feat": false,
		"skill_points_bonus": 0,
		"effects": {"will_bonus": 1},
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
		"effects": {"fort_bonus": 1},
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
		"effects": {"fort_bonus": 1, "ref_bonus": 1, "will_bonus": 1},
		"traits": ["+1 CA y +1 a ataque por tamaño pequeño", "+2 a Moverse Sigilosamente", "+1 a todas las salvaciones"],
		"favored_class": "Pícaro",
	},
	"half_elf": {
		"name": "Semielfo",
		"ability_adjustments": {},
		"size": "Medio",
		"speed": 9,
		"bonus_feat": false,
		"skill_points_bonus": 1,
		"effects": {},
		"traits": ["Visión en penumbra", "Inmune a sueño mágico", "+2 a Diplomacia y Sentir Motivación", "Se adapta bien entre humanos y elfos"],
		"favored_class": "Cualquiera",
	},
	"half_orc": {
		"name": "Semiorco",
		"ability_adjustments": {"str": 2, "int": -2, "cha": -2},
		"size": "Medio",
		"speed": 9,
		"bonus_feat": false,
		"skill_points_bonus": 0,
		"effects": {},
		"traits": ["Visión en la oscuridad 18m", "Fuerza propia de su sangre orca"],
		"favored_class": "Bárbaro",
	},
	"gnome": {
		"name": "Gnomo",
		"ability_adjustments": {"con": 2, "str": -2},
		"size": "Pequeño",
		"speed": 6,
		"bonus_feat": false,
		"skill_points_bonus": 0,
		"effects": {"will_bonus": 1},
		"traits": ["Visión en penumbra", "+2 a salvación vs. ilusiones", "Afinidad con magia menor", "+1 CA y +1 a ataque por tamaño pequeño"],
		"favored_class": "Mago",
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


static func size_attack_modifier(size: String) -> int:
	match size:
		"Pequeño": return 1
		"Grande": return -1
		_: return 0
