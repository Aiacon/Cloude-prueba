extends RefCounted
## Motor de combate por turnos basado en las reglas SRD 3.5: iniciativa, ataque vs CA, daño, salvaciones.
class_name CombatEngine

const CRITICAL_THRESHOLD := 20  # 20 natural = amenaza de crítico (x2 simplificado, sin rango de amenaza por arma)

class AttackResult:
	var attack_roll: int
	var natural_roll: int
	var total_attack: int
	var hit: bool
	var critical: bool
	var damage: int


## Tirada de iniciativa: d20 + mod. DES. Devuelve la lista ordenada de mayor a menor.
static func roll_initiative_order(combatants: Array) -> Array:
	var entries: Array = []
	for c in combatants:
		var roll: int = Dice.d20() + c.abilities.dex_mod()
		entries.append({"combatant": c, "initiative": roll})
	entries.sort_custom(func(a, b): return a["initiative"] > b["initiative"])
	return entries


## Resuelve un ataque cuerpo a cuerpo/distancia contra la Clase de Armadura objetivo.
static func resolve_attack(attack_bonus: int, target_ac: int, damage_expression: String, damage_bonus: int) -> AttackResult:
	var result := AttackResult.new()
	result.natural_roll = Dice.d20()
	result.attack_roll = result.natural_roll
	result.total_attack = result.natural_roll + attack_bonus
	result.critical = result.natural_roll >= CRITICAL_THRESHOLD

	if result.natural_roll == 1:
		result.hit = false
	elif result.natural_roll == 20:
		result.hit = true
	else:
		result.hit = result.total_attack >= target_ac

	if result.hit:
		var dmg: int = max(1, Dice.roll_expression(damage_expression) + damage_bonus)
		if result.critical:
			dmg += max(1, Dice.roll_expression(damage_expression) + damage_bonus)  # x2 simplificado
		result.damage = dmg
	else:
		result.damage = 0
	return result


## Tirada de salvación: d20 + bonificador vs CD. True si tiene éxito.
static func resolve_save(save_bonus: int, dc: int) -> bool:
	var roll := Dice.d20()
	if roll == 1:
		return false
	if roll == 20:
		return true
	return (roll + save_bonus) >= dc


## CD de salvación estándar: 10 + mitad de nivel/DG + mod. de la característica clave.
static func save_dc(caster_level: int, key_ability_mod: int) -> int:
	return 10 + int(caster_level / 2.0) + key_ability_mod
