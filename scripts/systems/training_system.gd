extends RefCounted
class_name TrainingSystem

static func durations() -> Dictionary:
	return {"strength": 30, "defense": 40, "tech": 45}

static func reward_for(kind: String, quality: float, level: int) -> Dictionary:
	var gains := {}
	match kind:
		"strength":
			gains = {"attack": 1.0 + quality, "hp": 0.5}
		"defense":
			gains = {"defense": 1.0 + quality, "hp": 1.2}
		"tech":
			gains = {"tech": 1.0 + quality, "energy": 1.0}
		_:
			gains = {"luck": 1.0}
	for key in gains.keys():
		gains[key] = gains[key] + level * 0.05
	return gains
