extends RefCounted
class_name PetsData

static func starters() -> Array:
	return [
		{
			"id": "aggressive",
			"name": "Riot Hound",
			"description": "High attack growth cyber-beast.",
			"color": Color("ff6b6b"),
			"base_stats": {"hp": 34, "attack": 8, "defense": 4, "speed": 5, "tech": 3, "energy": 8, "luck": 3},
			"growth": {"hp": 1.5, "attack": 1.6, "defense": 0.9, "speed": 1.0, "tech": 0.8, "energy": 1.0, "luck": 0.7}
		},
		{
			"id": "tactical",
			"name": "Aegis Sprite",
			"description": "Defensive utility specialist.",
			"color": Color("7bdff2"),
			"base_stats": {"hp": 38, "attack": 5, "defense": 8, "speed": 4, "tech": 5, "energy": 7, "luck": 4},
			"growth": {"hp": 1.7, "attack": 0.9, "defense": 1.5, "speed": 0.9, "tech": 1.2, "energy": 1.0, "luck": 0.8}
		},
		{
			"id": "arcane",
			"name": "Hex Mite",
			"description": "Tech/energy focused caster.",
			"color": Color("c792ea"),
			"base_stats": {"hp": 30, "attack": 4, "defense": 4, "speed": 6, "tech": 9, "energy": 11, "luck": 5},
			"growth": {"hp": 1.1, "attack": 0.8, "defense": 0.8, "speed": 1.2, "tech": 1.7, "energy": 1.8, "luck": 1.0}
		}
	]
