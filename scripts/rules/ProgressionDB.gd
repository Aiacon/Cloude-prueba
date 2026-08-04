extends Node
## Progresión de personaje hasta nivel 30 (niveles épicos 21-30 incluidos),
## siguiendo la tabla de experiencia estándar del SRD 3.5.
class_name ProgressionDB

const MAX_LEVEL := 30

## XP acumulada necesaria para alcanzar "level" (fórmula oficial: 500*N*(N-1)).
static func xp_for_level(level: int) -> int:
	return 500 * level * (level - 1)


## Se gana una dote general en 1er nivel y cada 3 niveles (incluye rango épico).
static func grants_general_feat(level: int) -> bool:
	return level == 1 or (level % 3 == 0)


## El Guerrero gana una dote de combate adicional en estos niveles (SRD + progresión épica).
static func grants_fighter_bonus_feat(level: int) -> bool:
	return level == 1 or (level % 2 == 0)


## Cada 4 niveles se gana +1 a una característica a elección (según el rol de la clase).
static func grants_ability_increase(level: int) -> bool:
	return level % 4 == 0


static func is_epic(level: int) -> bool:
	return level > 20
