extends RefCounted
class_name Models

static func stat_keys() -> Array[String]:
	return ["hp", "attack", "defense", "speed", "tech", "energy", "luck"]

static func blank_inventory() -> Dictionary:
	return {"gear": [], "implants": [], "materials": 0, "credits": 0}

static func default_meta_upgrades() -> Dictionary:
	return {
		"base_hp": {"name": "+Base HP", "level": 0, "max": 5, "base_cost": 2, "cost_scale": 2, "per_level": 4},
		"base_attack": {"name": "+Base Attack", "level": 0, "max": 5, "base_cost": 2, "cost_scale": 2, "per_level": 1},
		"training_speed": {"name": "+Training Speed %", "level": 0, "max": 5, "base_cost": 3, "cost_scale": 3, "per_level": 0.08},
		"activity_reward": {"name": "+Activity Reward %", "level": 0, "max": 5, "base_cost": 3, "cost_scale": 3, "per_level": 0.1}
	}

static func xp_to_next(level: int) -> int:
	return 30 + level * 18
