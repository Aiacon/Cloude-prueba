extends Node
## Lista simplificada de habilidades D&D 3.5 y su característica clave.
class_name SkillDB

const SKILLS := {
	"Trepar": "str",
	"Nadar": "str",
	"Saltar": "str",
	"Moverse Sigilosamente": "dex",
	"Sigilo": "dex",
	"Abrir Cerraduras": "dex",
	"Montar": "dex",
	"Concentración": "con",
	"Buscar": "int",
	"Conocimiento (arcano)": "int",
	"Conocimiento (elemental)": "int",
	"Conocimiento (religión)": "int",
	"Saber": "int",
	"Detectar Trampas": "wis",
	"Escuchar": "wis",
	"Sentir Motivación": "wis",
	"Curar": "wis",
	"Diplomacia": "cha",
	"Intimidar": "cha",
	"Manejar Animales": "cha",
}


static func key_ability(skill_name: String) -> String:
	return SKILLS.get(skill_name, "int")


static func all_names() -> Array:
	return SKILLS.keys()
