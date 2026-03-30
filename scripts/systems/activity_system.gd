extends RefCounted
class_name ActivitySystem

static func durations() -> Dictionary:
	return {"scavenge": 50, "recovery": 35}

static func reward_for(kind: String, bonus_mult: float) -> Dictionary:
	if kind == "scavenge":
		return {
			"credits": int((24 + randi_range(0, 18)) * bonus_mult),
			"materials": int((8 + randi_range(0, 6)) * bonus_mult),
			"gear_drop": randf() < 0.35,
			"implant_drop": randf() < 0.2
		}
	return {
		"energy": 16,
		"mood": 14,
		"hp": 5
	}
