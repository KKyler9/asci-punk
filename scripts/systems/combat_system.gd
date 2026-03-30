extends RefCounted
class_name CombatSystem

static func damage(atk: int, defense: int, variance := 2) -> int:
	var raw := atk - int(defense * 0.45) + randi_range(-variance, variance)
	return maxi(1, raw)

static func ability_name(implants: Array) -> String:
	if implants.is_empty():
		return "No Implant"
	return str(implants[0])
