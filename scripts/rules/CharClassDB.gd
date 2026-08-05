extends Node
## Base de datos de clases jugables (reglas SRD 3.5 / OGL, simplificadas para un RPG retro).
class_name CharClassDB

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
		"spell_start_level": 0,
		"role": "melee",
		"primary_ability": "str",
		"starting_weapon": "espada_larga",
		"starting_armor": "cota_escamas",
		"starting_shield": "escudo_grande",
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
		"spell_start_level": 1,
		"max_spell_level_cap": 9,
		"role": "healer",
		"primary_ability": "wis",
		"starting_weapon": "mazo_pesado",
		"starting_armor": "cota_cuero",
		"starting_shield": "escudo_pequeno",
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
		"spell_start_level": 1,
		"max_spell_level_cap": 9,
		"role": "arcane",
		"primary_ability": "int",
		"starting_weapon": "baston",
		"starting_armor": "",
		"starting_shield": "",
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
		"spell_start_level": 0,
		"role": "skill",
		"sneak_attack_dice": true,  # +1d6 cada 2 niveles
		"primary_ability": "dex",
		"starting_weapon": "daga",
		"starting_armor": "cota_cuero",
		"starting_shield": "",
	},
	"ranger": {
		"name": "Explorador",
		"hit_die": 8,
		"bab_progression": "good",
		"fort_progression": "good",
		"ref_progression": "good",
		"will_progression": "poor",
		"skill_points_per_level": 6,
		"class_skills": ["Buscar", "Sigilo", "Moverse Sigilosamente", "Sobrevivir", "Manejar Animales", "Escuchar"],
		"casts_spells": true,
		"spellcasting_ability": "wis",
		"spell_start_level": 4,
		"max_spell_level_cap": 4,
		"role": "hybrid",
		"primary_ability": "dex",
		"starting_weapon": "arco_corto",
		"starting_armor": "cota_cuero",
		"starting_shield": "",
	},
	"paladin": {
		"name": "Paladín",
		"hit_die": 10,
		"bab_progression": "good",
		"fort_progression": "good",
		"ref_progression": "poor",
		"will_progression": "poor",
		"skill_points_per_level": 2,
		"class_skills": ["Diplomacia", "Curar", "Conocimiento (religión)", "Sentir Motivación", "Montar"],
		"casts_spells": true,
		"spellcasting_ability": "wis",
		"spell_start_level": 4,
		"max_spell_level_cap": 4,
		"role": "hybrid",
		"primary_ability": "str",
		"starting_weapon": "espada_larga",
		"starting_armor": "cota_mallas",
		"starting_shield": "escudo_grande",
	},
}


static func get_class_data(id: String) -> Dictionary:
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
	var data := get_class_data(class_id)
	if not data.get("sneak_attack_dice", false):
		return 0
	return int(ceil(level / 2.0))


static func primary_ability(class_id: String) -> String:
	return get_class_data(class_id).get("primary_ability", "str")


## Nivel de conjurador efectivo (0 si aún no puede lanzar conjuros a este nivel de personaje).
static func caster_level(class_id: String, level: int) -> int:
	var data := get_class_data(class_id)
	if not data.get("casts_spells", false):
		return 0
	var start: int = data.get("spell_start_level", 1)
	if start == 0 or level < start:
		return 0
	return level - start + 1


## Nivel máximo de conjuro que puede lanzar (misma progresión que el SRD: nivel de
## conjuro 9 se alcanza a nivel de conjurador 17 para los conjuradores completos).
static func max_spell_level(class_id: String, level: int) -> int:
	var cl := caster_level(class_id, level)
	if cl <= 0:
		return -1
	var formula_level: int = int((cl + 1) / 2.0)
	var cap: int = get_class_data(class_id).get("max_spell_level_cap", 0)
	return min(formula_level, cap)


## Sistema de conjuros simplificado: en vez de espacios independientes por nivel de
## conjuro (regla completa del SRD), el conjurador dispone de una reserva de Puntos de
## Maná (variante "spell points" de Unearthed Arcana) que gasta según el nivel del
## conjuro (ver SpellDB.mana_cost) en cualquier conjuro conocido hasta su nivel máximo.
static func mana_per_day(class_id: String, level: int) -> int:
	var cl := caster_level(class_id, level)
	if cl <= 0:
		return 0
	return 3 * cl + 2
