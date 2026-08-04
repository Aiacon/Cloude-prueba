extends Node
## Conjuros (contenido de reglas basado en el SRD 3.5 / OGL, con temática elemental
## propia). Sistema simplificado: cada conjurador conoce automáticamente todos los
## conjuros de su clase hasta el nivel máximo que le permite su nivel de conjurador,
## y gasta "usos de conjuro" diarios en vez de espacios independientes por nivel
## (ver ClassDB.spells_per_day / max_spell_level).
class_name SpellDB

# effect: "damage" | "heal" | "buff_ac" | "buff_attack" | "debuff_ac"
# save: "none" | "fort" | "ref" | "will" (si aplica, éxito = mitad de daño)
const SPELLS := {
	# --- Nivel 0 (trucos) ---
	"chispa_electrica": {"name": "Chispa Eléctrica", "level": 0, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "1d3", "save": "none", "target": "enemy", "description": "Una pequeña descarga que castiga a un solo enemigo."},
	"luz": {"name": "Luz", "level": 0, "classes": ["wizard", "cleric"], "school": "Evocación", "effect": "buff_ac", "expression": "0", "save": "none", "target": "self", "description": "Ilumina el entorno (efecto narrativo)."},
	"orar": {"name": "Plegaria Menor", "level": 0, "classes": ["cleric"], "school": "Abjuración", "effect": "heal", "expression": "1d3", "save": "none", "target": "ally", "description": "Una bendición sencilla que cierra heridas leves."},
	"toque_gelido": {"name": "Toque Gélido", "level": 0, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "1d3", "save": "none", "target": "enemy", "description": "Frío elemental menor concentrado en un golpe."},
	"guia": {"name": "Guía", "level": 0, "classes": ["cleric"], "school": "Adivinación", "effect": "buff_attack", "expression": "1", "save": "none", "target": "ally", "description": "Favor divino que agudiza la puntería de un aliado."},
	"resistencia_menor": {"name": "Resistencia Menor", "level": 0, "classes": ["cleric", "paladin"], "school": "Abjuración", "effect": "buff_ac", "expression": "1", "save": "none", "target": "ally", "description": "Un manto de protección apenas perceptible."},

	# --- Nivel 1 ---
	"proyectil_magico": {"name": "Proyectil Mágico", "level": 1, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "2d4+1", "save": "none", "target": "enemy", "description": "Dardos de energía arcana que nunca fallan."},
	"escudo_de_fuego_menor": {"name": "Escudo Ígneo Menor", "level": 1, "classes": ["wizard"], "school": "Evocación", "effect": "buff_ac", "expression": "2", "save": "none", "target": "self", "description": "Llamas defensivas que desvían los golpes."},
	"curar_heridas_leves": {"name": "Curar Heridas Leves", "level": 1, "classes": ["cleric", "paladin"], "school": "Conjuración", "effect": "heal", "expression": "1d8+1", "save": "none", "target": "ally", "description": "Energía positiva que cierra heridas."},
	"bendicion": {"name": "Bendición", "level": 1, "classes": ["cleric", "paladin"], "school": "Encantamiento", "effect": "buff_attack", "expression": "1", "save": "none", "target": "ally", "description": "El favor divino agudiza el filo de las armas aliadas."},
	"enmarañar": {"name": "Enmarañar", "level": 1, "classes": ["ranger"], "school": "Transmutación", "effect": "debuff_ac", "expression": "2", "save": "ref", "target": "enemy", "description": "Raíces y lianas dificultan la defensa del objetivo."},
	"golpe_de_viento": {"name": "Golpe de Viento", "level": 1, "classes": ["wizard", "ranger"], "school": "Evocación", "effect": "damage", "expression": "1d6+1", "save": "ref", "target": "enemy", "description": "Una ráfaga cortante propia del Ala del Aire."},

	# --- Nivel 2 ---
	"latigo_de_fuego": {"name": "Látigo de Fuego", "level": 2, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "3d4", "save": "ref", "target": "enemy", "description": "Un azote de llamas que castiga la carne desprotegida."},
	"piel_de_piedra_menor": {"name": "Piel de Piedra Menor", "level": 2, "classes": ["wizard", "cleric"], "school": "Abjuración", "effect": "buff_ac", "expression": "3", "save": "none", "target": "self", "description": "La piel se endurece como granito por un instante."},
	"curar_heridas_moderadas": {"name": "Curar Heridas Moderadas", "level": 2, "classes": ["cleric", "paladin"], "school": "Conjuración", "effect": "heal", "expression": "2d8+3", "save": "none", "target": "ally", "description": "Una oleada de energía positiva más intensa."},
	"gracia_del_aire": {"name": "Gracia del Aire", "level": 2, "classes": ["cleric", "ranger"], "school": "Transmutación", "effect": "buff_ac", "expression": "2", "save": "none", "target": "ally", "description": "Los pies del receptor apenas rozan el suelo."},
	"flecha_acida": {"name": "Flecha Ácida", "level": 2, "classes": ["wizard"], "school": "Conjuración", "effect": "damage", "expression": "2d6", "save": "none", "target": "enemy", "description": "Ácido corrosivo que ignora la armadura convencional."},

	# --- Nivel 3 ---
	"bola_de_fuego_menor": {"name": "Bola de Fuego Menor", "level": 3, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "5d6", "save": "ref", "target": "all_enemies", "description": "Una esfera de fuego que castiga a todo el grupo enemigo."},
	"oleada_curativa": {"name": "Oleada Curativa", "level": 3, "classes": ["cleric", "paladin"], "school": "Conjuración", "effect": "heal", "expression": "3d8+3", "save": "none", "target": "ally", "description": "Restaura una cantidad sustancial de vitalidad."},
	"armadura_de_hielo": {"name": "Armadura de Hielo", "level": 3, "classes": ["wizard"], "school": "Evocación", "effect": "buff_ac", "expression": "4", "save": "none", "target": "self", "description": "Una coraza de hielo tan dura como el acero."},
	"llamada_del_trueno": {"name": "Llamada del Trueno", "level": 3, "classes": ["cleric", "ranger"], "school": "Evocación", "effect": "damage", "expression": "4d6", "save": "fort", "target": "enemy", "description": "Un estruendo que sacude cuerpo y mente del objetivo."},
	"proteccion_elemental": {"name": "Protección Elemental", "level": 3, "classes": ["cleric", "paladin"], "school": "Abjuración", "effect": "buff_ac", "expression": "3", "save": "none", "target": "ally", "description": "Aísla al receptor de los cuatro elementos por un tiempo."},

	# --- Nivel 4 ---
	"tormenta_de_arena": {"name": "Tormenta de Arena", "level": 4, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "6d6", "save": "ref", "target": "all_enemies", "description": "Arena y esquirlas de piedra a gran velocidad."},
	"curar_heridas_graves": {"name": "Curar Heridas Graves", "level": 4, "classes": ["cleric", "paladin"], "school": "Conjuración", "effect": "heal", "expression": "4d8+4", "save": "none", "target": "ally", "description": "Una potente descarga de energía positiva."},
	"piel_de_piedra": {"name": "Piel de Piedra", "level": 4, "classes": ["wizard", "ranger"], "school": "Abjuración", "effect": "buff_ac", "expression": "5", "save": "none", "target": "self", "description": "La piel se vuelve literalmente pétrea."},
	"maldicion_del_pantano": {"name": "Maldición del Pantano", "level": 4, "classes": ["cleric"], "school": "Nigromancia", "effect": "debuff_ac", "expression": "4", "save": "will", "target": "enemy", "description": "Debilita las defensas del objetivo con energía negativa."},
	"furia_elemental": {"name": "Furia Elemental", "level": 4, "classes": ["ranger", "wizard"], "school": "Evocación", "effect": "damage", "expression": "5d8", "save": "fort", "target": "enemy", "description": "Concentra la ira de los cuatro elementos en un solo golpe."},

	# --- Nivel 5 (solo conjuradores completos: Clérigo/Mago) ---
	"bola_de_fuego": {"name": "Bola de Fuego", "level": 5, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "8d6", "save": "ref", "target": "all_enemies", "description": "La clásica esfera explosiva de fuego arcano."},
	"curacion_en_masa_menor": {"name": "Curación en Masa Menor", "level": 5, "classes": ["cleric"], "school": "Conjuración", "effect": "heal", "expression": "5d8+5", "save": "none", "target": "ally", "description": "Restaura grandes cantidades de vitalidad de golpe."},
	"muro_de_hielo": {"name": "Muro de Hielo", "level": 5, "classes": ["wizard"], "school": "Evocación", "effect": "buff_ac", "expression": "6", "save": "none", "target": "ally", "description": "Una barrera helada que se interpone ante los golpes."},
	"terremoto_menor": {"name": "Terremoto Menor", "level": 5, "classes": ["cleric"], "school": "Evocación", "effect": "damage", "expression": "7d6", "save": "fort", "target": "all_enemies", "description": "La tierra misma castiga a quienes profanan el templo."},

	# --- Nivel 6 ---
	"cadena_de_relampagos": {"name": "Cadena de Relámpagos", "level": 6, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "9d6", "save": "ref", "target": "all_enemies", "description": "Un arco eléctrico que salta entre todos los enemigos."},
	"curacion_completa": {"name": "Curación Completa", "level": 6, "classes": ["cleric"], "school": "Conjuración", "effect": "heal", "expression": "7d8+7", "save": "none", "target": "ally", "description": "Cierra casi cualquier herida al instante."},
	"forma_de_piedra_viva": {"name": "Forma de Piedra Viva", "level": 6, "classes": ["wizard"], "school": "Transmutación", "effect": "buff_ac", "expression": "7", "save": "none", "target": "self", "description": "El cuerpo se vuelve tan resistente como una estatua."},
	"ira_de_los_elementos": {"name": "Ira de los Elementos", "level": 6, "classes": ["cleric"], "school": "Evocación", "effect": "damage", "expression": "9d6", "save": "will", "target": "enemy", "description": "Los cuatro elementos convergen sobre un único enemigo."},

	# --- Nivel 7 ---
	"meteoro_menor": {"name": "Meteoro Menor", "level": 7, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "11d6", "save": "ref", "target": "all_enemies", "description": "Fragmentos incandescentes caen sobre el campo de batalla."},
	"regeneracion": {"name": "Regeneración", "level": 7, "classes": ["cleric"], "school": "Conjuración", "effect": "heal", "expression": "9d8+9", "save": "none", "target": "ally", "description": "El cuerpo se repara a una velocidad asombrosa."},
	"muralla_de_los_elementos": {"name": "Muralla de los Elementos", "level": 7, "classes": ["wizard", "cleric"], "school": "Abjuración", "effect": "buff_ac", "expression": "8", "save": "none", "target": "ally", "description": "Los cuatro elementos forman una barrera alrededor del receptor."},

	# --- Nivel 8 ---
	"tormenta_elemental": {"name": "Tormenta Elemental", "level": 8, "classes": ["wizard"], "school": "Evocación", "effect": "damage", "expression": "13d6", "save": "ref", "target": "all_enemies", "description": "Fuego, hielo, viento y piedra caen a la vez sobre los enemigos."},
	"santuario_divino": {"name": "Santuario Divino", "level": 8, "classes": ["cleric"], "school": "Conjuración", "effect": "heal", "expression": "11d8+11", "save": "none", "target": "ally", "description": "Un pulso de energía divina que restaura por completo a un aliado."},

	# --- Nivel 9 ---
	"juicio_elemental": {"name": "Juicio Elemental", "level": 9, "classes": ["wizard", "cleric"], "school": "Evocación", "effect": "damage", "expression": "16d6", "save": "fort", "target": "all_enemies", "description": "El poder combinado del Nexo Elemental se abate sobre los enemigos."},
	"resurreccion_menor": {"name": "Restauración Suprema", "level": 9, "classes": ["cleric"], "school": "Conjuración", "effect": "heal", "expression": "15d8+15", "save": "none", "target": "ally", "description": "El conjuro de curación más poderoso conocido por los clérigos."},
}


static func get_spell(id: String) -> Dictionary:
	return SPELLS.get(id, {})


## Conjuros que "class_id" conoce automáticamente hasta el nivel de personaje dado.
static func known_spells_for(class_id: String, character_level: int) -> Array:
	var max_level := ClassDB.max_spell_level(class_id, character_level)
	if max_level < 0:
		return []
	var result: Array = []
	for id in SPELLS:
		var spell: Dictionary = SPELLS[id]
		if spell["classes"].has(class_id) and spell["level"] <= max_level:
			result.append(id)
	return result
