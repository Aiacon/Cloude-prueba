extends Node
## Base de datos de clases jugables (reglas SRD 3.5 / OGL, simplificadas para un RPG retro).
class_name ClassDB

# progression: "good" | "average" | "poor" para BAB y salvaciones.
const CLASSES := {
	"fighter": {
		"name": "Guerrero",
		"hit_die": 10,
		"bab_progression": "good",
		"fort_progression": "good",
		"ref_progression": "poor",
		"will_progression": "poor",
		"skill_points_per_level": 2,
		"class_skills": ["Trepar", "Manejar Animales", "Intimidar", "Saltar", "Montar", "Nadar"],
		"casts_spells": false,
		"spellcasting_ability": "",
		"role": "melee",
	},
	"cleric": {
		"name": "Clérigo",
		"hit_die": 8,
		"bab_progression": "average",
		"fort_progression": "good",
		"ref_progression": "poor",
		"will_progression": "good",
		"skill_points_per_level": 2,
		"class_skills": ["Concentración", "Curar", "Conocimiento (religión)", "Diplomacia", "Sentir Motivación"],
		"casts_spells": true,
		"spellcasting_ability": "wis",
		"role": "healer",
	},
	"wizard": {
		"name": "Mago",
		"hit_die": 4,
		"bab_progression": "poor",
		"fort_progression": "poor",
		"ref_progression": "poor",
		"will_progression": "good",
		"skill_points_per_level": 2,
		"class_skills": ["Concentración", "Conocimiento (arcano)", "Conocimiento (elemental)", "Saber", "Buscar"],
		"casts_spells": true,
		"spellcasting_ability": "int",
		"role": "arcane",
	},
	"rogue": {
		"name": "Pícaro",
		"hit_die": 6,
		"bab_progression": "average",
		"fort_progression": "poor",
		"ref_progression": "good",
		"will_progression": "poor",
		"skill_points_per_level": 8,
		"class_skills": ["Buscar", "Sigilo", "Moverse Sigilosamente", "Abrir Cerraduras", "Detectar Trampas", "Escuchar"],
		"casts_spells": false,
		"spellcasting_ability": "",
		"role": "skill",
		"sneak_attack_dice": true,  # +1d6 cada 2 niveles
	},
}


static func get_class(id: String) -> Dictionary:
	return CLASSES.get(id, CLASSES["fighter"])


static func ids() -> Array:
	return CLASSES.keys()


## BAB según SRD: bueno = nivel, medio = nivel*3/4, pobre = nivel/2 (enteros truncados).
static func base_attack_bonus(progression: String, level: int) -> int:
	match progression:
		"good": return level
		"average": return int(level * 3 / 4.0)
		"poor": return int(level / 2.0)
		_: return 0


## Salvaciones según SRD: buena = 2 + nivel/2, pobre = nivel/3 (enteros truncados).
static func base_save_bonus(progression: String, level: int) -> int:
	match progression:
		"good": return 2 + int(level / 2.0)
		"poor": return int(level / 3.0)
		_: return 0


static func sneak_attack_dice(class_id: String, level: int) -> int:
	var data := get_class(class_id)
	if not data.get("sneak_attack_dice", false):
		return 0
	return int(ceil(level / 2.0))
