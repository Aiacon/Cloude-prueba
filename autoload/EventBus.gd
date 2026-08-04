extends Node
## Bus de señales globales para desacoplar UI, combate y mundo.

signal encounter_started(enemies: Array)
signal encounter_ended(victory: bool)
signal party_member_leveled_up(character)
signal dialogue_requested(lines: Array, speaker: String)
signal inventory_changed()
signal game_message(text: String)
