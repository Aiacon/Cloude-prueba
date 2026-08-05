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
		"visual": {"skin": Color(0.87, 0.68, 0.53), "height": 1.0, "width": 1.0, "ear": "none", "beard": false},
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
		"visual": {"skin": Color(0.93, 0.82, 0.68), "height": 1.08, "width": 0.88, "ear": "pointed", "beard": false},
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
		"visual": {"skin": Color(0.82, 0.6, 0.47), "height": 0.75, "width": 1.25, "ear": "none", "beard": true},
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
		"visual": {"skin": Color(0.85, 0.66, 0.5), "height": 0.65, "width": 0.85, "ear": "none", "beard": false},
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
		"visual": {"skin": Color(0.88, 0.72, 0.56), "height": 1.03, "width": 0.95, "ear": "pointed", "beard": false},
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
		"visual": {"skin": Color(0.64, 0.73, 0.52), "height": 1.1, "width": 1.15, "ear": "none", "beard": false},
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
		"visual": {"skin": Color(0.92, 0.78, 0.65), "height": 0.68, "width": 0.85, "ear": "pointed", "beard": false},
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
