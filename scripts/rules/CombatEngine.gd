extends RefCounted
## Motor de combate por turnos basado en las reglas SRD 3.5: iniciativa, ataque vs CA, daño,
## salvaciones. Todas las resoluciones incluyen un desglose legible de la tirada para
## mostrarlo en el registro de combate ("quiero ver las tiradas de dados").
class_name CombatEngine

const CRITICAL_THRESHOLD := 20  # 20 natural = amenaza de crítico (x2 simplificado, sin rango de amenaza por arma)

class AttackResult:
	var natural_roll: int
	var total_attack: int
	var hit: bool
	var critical: bool
	var damage: int
	var breakdown: String


class SaveResult:
	var natural_roll: int
	var total_save: int
	var success: bool
	var breakdown: String


## Tirada de iniciativa: d20 + mod. DES + dotes. Devuelve la lista ordenada de mayor a menor.
static func roll_initiative_order(combatants: Array) -> Array:
	var entries: Array = []
	for c in combatants:
		var natural := Dice.d20()
		var bonus: int = c.abilities.dex_mod() + c.feat_bonus("initiative_bonus")
		var roll: int = natural + bonus
		entries.append({"combatant": c, "initiative": roll, "breakdown": "d20(%d)%s = %d" % [natural, _signed(bonus), roll]})
	entries.sort_custom(func(a, b): return a["initiative"] > b["initiative"])
	return entries


## Resuelve un ataque cuerpo a cuerpo/distancia contra la Clase de Armadura objetivo.
static func resolve_attack(attack_bonus: int, target_ac: int, damage_expression: String, damage_bonus: int) -> AttackResult:
	var result := AttackResult.new()
	result.natural_roll = Dice.d20()
	result.total_attack = result.natural_roll + attack_bonus
	result.critical = result.natural_roll >= CRITICAL_THRESHOLD

	if result.natural_roll == 1:
		result.hit = false
	elif result.natural_roll == 20:
		result.hit = true
	else:
		result.hit = result.total_attack >= target_ac

	result.breakdown = "d20(%d)%s = %d vs CA %d" % [result.natural_roll, _signed(attack_bonus), result.total_attack, target_ac]

	if result.hit:
		var dmg: int = max(1, Dice.roll_expression(damage_expression) + damage_bonus)
		if result.critical:
			dmg += max(1, Dice.roll_expression(damage_expression) + damage_bonus)  # x2 simplificado
		result.damage = dmg
	else:
		result.damage = 0
	return result


## Tirada de salvación: d20 + bonificador vs CD.
static func resolve_save(save_bonus: int, dc: int) -> SaveResult:
	var result := SaveResult.new()
	result.natural_roll = Dice.d20()
	result.total_save = result.natural_roll + save_bonus

	if result.natural_roll == 1:
		result.success = false
	elif result.natural_roll == 20:
		result.success = true
	else:
		result.success = result.total_save >= dc

	result.breakdown = "d20(%d)%s = %d vs CD %d" % [result.natural_roll, _signed(save_bonus), result.total_save, dc]
	return result


## CD de salvación estándar: 10 + mitad de nivel/DG + mod. de la característica clave.
static func save_dc(caster_level: int, key_ability_mod: int) -> int:
	return 10 + int(caster_level / 2.0) + key_ability_mod


static func _signed(value: int) -> String:
	return ("+%d" % value) if value >= 0 else ("%d" % value)
