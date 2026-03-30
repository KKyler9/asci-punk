extends RefCounted
class_name GearData

static func all() -> Dictionary:
	return {
		"neon_collar": {"name": "Neon Collar", "slot": "collar", "stats": {"attack": 2, "speed": 1}},
		"core_plating": {"name": "Core Plating", "slot": "plating", "stats": {"defense": 3, "hp": 8}},
		"booster_module": {"name": "Booster Module", "slot": "booster", "stats": {"speed": 2, "energy": 4}},
		"lucky_charm": {"name": "Lucky Charm", "slot": "trinket", "stats": {"luck": 3, "tech": 1}}
	}
