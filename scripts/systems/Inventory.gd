extends RefCounted
## Inventario simple de un personaje: lista de item_id -> cantidad, más oro.
class_name Inventory

var items: Dictionary = {}   # item_id -> cantidad
var gold: int = 0


func add_item(item_id: String, quantity: int = 1) -> void:
	items[item_id] = items.get(item_id, 0) + quantity
	EventBus.inventory_changed.emit()


func remove_item(item_id: String, quantity: int = 1) -> bool:
	if items.get(item_id, 0) < quantity:
		return false
	items[item_id] -= quantity
	if items[item_id] <= 0:
		items.erase(item_id)
	EventBus.inventory_changed.emit()
	return true


func has_item(item_id: String, quantity: int = 1) -> bool:
	return items.get(item_id, 0) >= quantity


func add_gold(amount: int) -> void:
	gold = max(0, gold + amount)


func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	return true


func to_dict() -> Dictionary:
	return {"items": items, "gold": gold}


static func from_dict(d: Dictionary) -> Inventory:
	var inv := Inventory.new()
	inv.items = d.get("items", {})
	inv.gold = d.get("gold", 0)
	return inv
