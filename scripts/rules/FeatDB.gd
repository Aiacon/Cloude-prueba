extends Node
## Dotes (feats) del SRD 3.5. Para mantener el combate simple y jugable, cada dote se
## traduce en un bonificador numérico agregado (mismo espíritu que la dote original,
## mecánica simplificada) en vez de implementar reglas especiales caso por caso.
class_name FeatDB

const FEATS := {
	"ataque_poderoso": {
		"name": "Ataque Poderoso",
		"description": "Sacrificas precisión por fuerza bruta en tus golpes.",
		"prereq": {"str": 13},
		"effects": {"damage_bonus": 2},
	},
	"foco_en_arma": {
		"name": "Foco en Arma",
		"description": "Entrenamiento extra con tu arma preferida.",
		"prereq": {},
		"effects": {"attack_bonus": 1},
	},
	"especializacion_arma": {
		"name": "Especialización en Arma",
		"description": "Dominio superior que añade daño consistente.",
		"prereq": {"requires_feat": "foco_en_arma", "class": ["fighter"], "level_min": 4},
		"effects": {"damage_bonus": 2},
	},
	"resistencia": {
		"name": "Resistencia (Toughness)",
		"description": "Tu cuerpo aguanta más castigo del habitual.",
		"prereq": {},
		"effects": {"hp_bonus": 3},
	},
	"iniciativa_mejorada": {
		"name": "Iniciativa Mejorada",
		"description": "Reaccionas más rápido al inicio del combate.",
		"prereq": {},
		"effects": {"initiative_bonus": 4},
	},
	"esquiva": {
		"name": "Esquiva (Dodge)",
		"description": "Un ligero movimiento constante te hace más difícil de alcanzar.",
		"prereq": {"dex": 13},
		"effects": {"ac_bonus": 1},
	},
	"gran_fortaleza": {
		"name": "Gran Fortaleza",
		"description": "Tu constitución te protege mejor de venenos y enfermedades.",
		"prereq": {},
		"effects": {"fort_bonus": 2},
	},
	"reflejos_rapidos": {
		"name": "Reflejos Rápidos",
		"description": "Reaccionas con agilidad ante el peligro.",
		"prereq": {},
		"effects": {"ref_bonus": 2},
	},
	"voluntad_de_hierro": {
		"name": "Voluntad de Hierro",
		"description": "Tu mente resiste mejor los efectos mentales.",
		"prereq": {},
		"effects": {"will_bonus": 2},
	},
	"disparo_a_quemarropa": {
		"name": "Disparo a Quemarropa",
		"description": "Mayor precisión y fuerza en ataques a distancia cercanos.",
		"prereq": {"dex": 13},
		"effects": {"ranged_attack_bonus": 1},
	},
	"tiro_lejano": {
		"name": "Tiro Certero",
		"description": "Compensas la distancia con puntería entrenada.",
		"prereq": {"requires_feat": "disparo_a_quemarropa"},
		"effects": {"ranged_attack_bonus": 1},
	},
	"combate_a_dos_armas": {
		"name": "Combate a Dos Armas",
		"description": "Reduces la penalización de luchar con un arma en cada mano.",
		"prereq": {"dex": 15},
		"effects": {"attack_bonus": 1},
	},
	"critico_mejorado": {
		"name": "Crítico Mejorado",
		"description": "Tus golpes certeros son aún más devastadores.",
		"prereq": {"bab": 8},
		"effects": {"damage_bonus": 2},
	},
	"conjuro_potenciado": {
		"name": "Conjuro Potenciado",
		"description": "Tus conjuros son más difíciles de resistir.",
		"prereq": {"class": ["wizard", "cleric"]},
		"effects": {"spell_dc_bonus": 1},
	},
	"foco_en_conjuros": {
		"name": "Foco en Conjuros",
		"description": "Especialización arcana que agudiza tus hechizos.",
		"prereq": {"class": ["wizard"]},
		"effects": {"spell_dc_bonus": 1},
	},
	"canalizar_energia_positiva": {
		"name": "Canalizar Energía Positiva",
		"description": "Tus curaciones son más potentes.",
		"prereq": {"class": ["cleric"]},
		"effects": {"heal_bonus": 2},
	},
	"ataque_furtivo_mejorado": {
		"name": "Golpe Certero",
		"description": "Refinas tu técnica de ataque furtivo.",
		"prereq": {"class": ["rogue"]},
		"effects": {"sneak_attack_bonus": 2},
	},
	"vitalidad_marcial": {
		"name": "Vitalidad Marcial",
		"description": "Condicionamiento físico extremo.",
		"prereq": {"class": ["fighter", "paladin", "ranger"]},
		"effects": {"hp_bonus": 3},
	},
	"golpe_aturdidor": {
		"name": "Golpe Aturdidor",
		"description": "Sabes dirigir tus golpes a puntos vitales.",
		"prereq": {"bab": 4},
		"effects": {"damage_bonus": 1, "attack_bonus": 1},
	},
	"agilidad_felina": {
		"name": "Agilidad Felina",
		"description": "Reflejos naturales entrenados al límite.",
		"prereq": {"dex": 15},
		"effects": {"ac_bonus": 1, "ref_bonus": 1},
	},
	"coraje_inquebrantable": {
		"name": "Coraje Inquebrantable",
		"description": "Tu determinación te sostiene en la batalla.",
		"prereq": {"cha": 13},
		"effects": {"will_bonus": 1, "hp_bonus": 2},
	},
	"maestria_marcial": {
		"name": "Maestría Marcial",
		"description": "Décadas de entrenamiento condensadas en instinto de combate.",
		"prereq": {"bab": 6},
		"effects": {"attack_bonus": 1, "damage_bonus": 1},
	},
	"armadura_ligera_mejorada": {
		"name": "Uso Mejorado de Armadura",
		"description": "Te mueves con soltura pese al peso de tu armadura.",
		"prereq": {},
		"effects": {"ac_bonus": 1},
	},
	"segunda_oportunidad": {
		"name": "Segunda Oportunidad",
		"description": "Un instinto de supervivencia afinado por incontables combates.",
		"prereq": {"level_min": 9},
		"effects": {"fort_bonus": 1, "ref_bonus": 1, "will_bonus": 1},
	},
	"leyenda_viviente": {
		"name": "Leyenda Viviente",
		"description": "Dote épica: tu nombre ya inspira temor y respeto.",
		"prereq": {"level_min": 21},
		"effects": {"attack_bonus": 1, "ac_bonus": 1, "hp_bonus": 5},
	},
	"poder_arcano_supremo": {
		"name": "Poder Arcano Supremo",
		"description": "Dote épica: tus conjuros alcanzan una intensidad devastadora.",
		"prereq": {"level_min": 21, "class": ["wizard"]},
		"effects": {"spell_dc_bonus": 2},
	},
	"furia_divina": {
		"name": "Furia Divina",
		"description": "Dote épica: la bendición de tu deidad refuerza cada golpe.",
		"prereq": {"level_min": 21, "class": ["cleric", "paladin"]},
		"effects": {"damage_bonus": 3, "heal_bonus": 3},
	},
	"reflejos_sobrehumanos": {
		"name": "Reflejos Sobrehumanos",
		"description": "Dote épica: te mueves más rápido de lo que el ojo puede seguir.",
		"prereq": {"level_min": 21, "class": ["rogue", "ranger"]},
		"effects": {"ac_bonus": 2, "ref_bonus": 2, "initiative_bonus": 4},
	},
	"cuerpo_de_acero": {
		"name": "Cuerpo de Acero",
		"description": "Dote épica: tu resistencia física roza lo sobrenatural.",
		"prereq": {"level_min": 24},
		"effects": {"hp_bonus": 10, "fort_bonus": 2},
	},
	"maestro_de_armas": {
		"name": "Maestro de Armas",
		"description": "Dote épica: ningún enemigo puede predecir tus ataques.",
		"prereq": {"level_min": 27, "class": ["fighter", "ranger", "paladin"]},
		"effects": {"attack_bonus": 2, "damage_bonus": 2},
	},
}


static func get_feat(id: String) -> Dictionary:
	return FEATS.get(id, {})


static func ids() -> Array:
	return FEATS.keys()


## Comprueba si "character" cumple los prerrequisitos de la dote "feat_id".
static func meets_prerequisites(character: Character, feat_id: String) -> bool:
	var feat := get_feat(feat_id)
	if feat.is_empty():
		return false
	var prereq: Dictionary = feat.get("prereq", {})

	if prereq.has("str") and character.abilities.strength < prereq["str"]:
		return false
	if prereq.has("dex") and character.abilities.dexterity < prereq["dex"]:
		return false
	if prereq.has("con") and character.abilities.constitution < prereq["con"]:
		return false
	if prereq.has("int") and character.abilities.intelligence < prereq["int"]:
		return false
	if prereq.has("wis") and character.abilities.wisdom < prereq["wis"]:
		return false
	if prereq.has("cha") and character.abilities.charisma < prereq["cha"]:
		return false
	if prereq.has("bab") and character.base_attack_bonus() < prereq["bab"]:
		return false
	if prereq.has("level_min") and character.level < prereq["level_min"]:
		return false
	if prereq.has("class") and not prereq["class"].has(character.class_id):
		return false
	if prereq.has("requires_feat") and not character.feats.has(prereq["requires_feat"]):
		return false
	return true


## Elige automáticamente la siguiente dote disponible para el personaje al subir de nivel,
## priorizando dotes acordes a su clase.
static func pick_feat_for(character: Character) -> String:
	var class_priority: Dictionary = {
		"fighter": ["foco_en_arma", "ataque_poderoso", "especializacion_arma", "maestria_marcial", "critico_mejorado", "golpe_aturdidor", "vitalidad_marcial", "resistencia"],
		"cleric": ["canalizar_energia_positiva", "conjuro_potenciado", "voluntad_de_hierro", "gran_fortaleza", "furia_divina", "resistencia"],
		"wizard": ["foco_en_conjuros", "conjuro_potenciado", "voluntad_de_hierro", "poder_arcano_supremo", "resistencia"],
		"rogue": ["ataque_furtivo_mejorado", "agilidad_felina", "reflejos_rapidos", "esquiva", "reflejos_sobrehumanos", "iniciativa_mejorada"],
		"ranger": ["disparo_a_quemarropa", "tiro_lejano", "combate_a_dos_armas", "esquiva", "reflejos_sobrehumanos", "maestro_de_armas"],
		"paladin": ["ataque_poderoso", "gran_fortaleza", "coraje_inquebrantable", "furia_divina", "maestro_de_armas", "vitalidad_marcial"],
	}
	var priority: Array = class_priority.get(character.class_id, FEATS.keys())
	for feat_id in priority:
		if not character.feats.has(feat_id) and meets_prerequisites(character, feat_id):
			return feat_id
	for feat_id in FEATS.keys():
		if not character.feats.has(feat_id) and meets_prerequisites(character, feat_id):
			return feat_id
	return ""
