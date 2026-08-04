extends Node
## Misiones dadas por NPC, concatenadas en una historia principal (6 capítulos a través
## de las 4 alas del Templo Elemental) más una misión secundaria opcional. Ambientación
## original.
class_name QuestDB

# objective_type: "reach_room" | "clear_encounter" | "collect_item"
const QUESTS := {
	"ecos_del_templo": {
		"name": "Ecos del Templo",
		"giver_npc": "alcalde_rodrigo",
		"objective_type": "reach_room",
		"objective_target": "entrada",
		"reward_gold": 50,
		"reward_xp": 0,
		"next_quest": "el_ala_del_fuego",
		"offer_text": ["Aventureros... el Templo Elemental ha despertado de nuevo.", "Lleguen hasta su vestíbulo y busquen al Hermano Ismael. Él sabrá guiarlos."],
		"complete_text": ["Bien, llegaron. El Hermano Ismael los espera dentro."],
	},
	"el_ala_del_fuego": {
		"name": "El Ala del Fuego",
		"giver_npc": "hermano_ismael",
		"objective_type": "clear_encounter",
		"objective_target": "ala_fuego:fuego_2",
		"reward_gold": 150,
		"reward_xp": 100,
		"next_quest": "el_ala_del_agua",
		"offer_text": ["El Ala del Fuego arde con una furia antinatural.", "Adéntrense y silencien al elemental que la custodia."],
		"complete_text": ["El fuego se calma... por ahora. Queda mucho templo por purificar."],
	},
	"el_ala_del_agua": {
		"name": "El Ala del Agua",
		"giver_npc": "hermano_ismael",
		"objective_type": "clear_encounter",
		"objective_target": "ala_agua:agua_1",
		"reward_gold": 150,
		"reward_xp": 100,
		"next_quest": "el_ala_del_aire",
		"offer_text": ["Ahora las mareas del Ala del Agua. Algo las agita desde dentro.", "Derroten al guardián que las controla."],
		"complete_text": ["Las aguas vuelven a fluir en calma."],
	},
	"el_ala_del_aire": {
		"name": "El Ala del Aire",
		"giver_npc": "hermano_ismael",
		"objective_type": "clear_encounter",
		"objective_target": "ala_aire:aire_2",
		"reward_gold": 150,
		"reward_xp": 100,
		"next_quest": "el_ala_de_la_tierra",
		"offer_text": ["Los vientos del Ala del Aire aúllan con furia elemental.", "Acaben con lo que los agita."],
		"complete_text": ["El aire se aquieta. Solo queda la Tierra."],
	},
	"el_ala_de_la_tierra": {
		"name": "El Ala de la Tierra",
		"giver_npc": "hermano_ismael",
		"objective_type": "clear_encounter",
		"objective_target": "ala_tierra:tierra_1",
		"reward_gold": 150,
		"reward_xp": 100,
		"next_quest": "el_corazon_del_nexo",
		"offer_text": ["El Ala de la Tierra tiembla bajo nuestros pies.", "El centinela que la guarda debe caer."],
		"complete_text": ["Las cuatro alas están purificadas. Ahora, el corazón del templo..."],
	},
	"el_corazon_del_nexo": {
		"name": "El Corazón del Nexo",
		"giver_npc": "hermano_ismael",
		"objective_type": "clear_encounter",
		"objective_target": "camara_final:boss",
		"reward_gold": 500,
		"reward_xp": 300,
		"next_quest": "",
		"offer_text": ["Con las cuatro llaves elementales, el Nexo se abrirá.", "Enfrenten al Sumo Sacerdote y pongan fin a esto."],
		"complete_text": ["Lo lograron. El Templo Elemental vuelve a estar en silencio.", "El pueblo les estará agradecido por generaciones."],
	},
	"el_amuleto_perdido": {
		"name": "El Amuleto Perdido",
		"giver_npc": "anciana_mistica",
		"objective_type": "collect_item",
		"objective_target": "llave_ala_agua",
		"reward_gold": 75,
		"reward_xp": 25,
		"next_quest": "",
		"offer_text": ["Hace años perdí un amuleto en las aguas de ese templo...", "Si encuentran la llave del Ala del Agua, sabré que están cerca. Tráiganmela y les pagaré bien."],
		"complete_text": ["¡La encontraron! Gracias, viajeros. Quédense la recompensa."],
	},
}

const MAIN_CHAIN := ["ecos_del_templo", "el_ala_del_fuego", "el_ala_del_agua", "el_ala_del_aire", "el_ala_de_la_tierra", "el_corazon_del_nexo"]


static func get_quest(id: String) -> Dictionary:
	return QUESTS.get(id, {})


## Estado de una misión: "" (no ofrecida), "active", o "completed".
static func state(quest_id: String) -> String:
	return GameManager.quest_states.get(quest_id, "")


static func is_objective_met(quest_id: String) -> bool:
	var quest := get_quest(quest_id)
	if quest.is_empty():
		return false
	match quest["objective_type"]:
		"reach_room":
			return GameManager.visited_rooms.get(quest["objective_target"], false)
		"clear_encounter":
			return GameManager.cleared_encounters.get(quest["objective_target"], false)
		"collect_item":
			var leader: Character = GameManager.party[0]
			return leader.inventory.has_item(quest["objective_target"])
		_:
			return false


## Próxima misión sin completar de la historia principal (vacío si ya se completó toda).
static func next_main_chain_quest() -> String:
	for quest_id in MAIN_CHAIN:
		if state(quest_id) != "completed":
			return quest_id
	return ""
