extends RefCounted
class_name ImplantData

static func all() -> Dictionary:
	return {
		"shock_pulse": {
			"name": "Shock Pulse",
			"ability": "Shock Pulse",
			"description": "Tech damage burst.",
			"energy_cost": 6,
			"passive": {"tech": 2}
		},
		"reactive_shield": {
			"name": "Reactive Shield",
			"ability": "Reactive Shield",
			"description": "Temporary defense up.",
			"energy_cost": 5,
			"passive": {"defense": 2}
		},
		"overclock": {
			"name": "Overclock",
			"ability": "Overclock",
			"description": "Attack/speed buff.",
			"energy_cost": 7,
			"passive": {"speed": 1, "attack": 1}
		},
		"nano_heal": {
			"name": "Nano Heal",
			"ability": "Nano Heal",
			"description": "Restore HP.",
			"energy_cost": 8,
			"passive": {"hp": 6}
		}
	}
