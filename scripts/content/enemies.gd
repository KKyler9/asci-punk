extends RefCounted
class_name EnemyData

static func all_enemies() -> Array[Dictionary]:
	return [
		{
			"id": "sentinel",
			"name": "Scrap Sentinel",
			"hp": 26,
			"attack": 5,
			"defense": 2,
			"speed": 3,
			"tech": 2,
			"xp": 16,
			"credits": 12,
			"frames": [" [o] \n-|#|-\n / \\", " [O] \n-|#|-\n / \\"]
		},
		{
			"id": "wisp",
			"name": "Firewall Wisp",
			"hp": 22,
			"attack": 6,
			"defense": 1,
			"speed": 5,
			"tech": 4,
			"xp": 17,
			"credits": 13,
			"frames": [" .*. \n(###)\n ' ' ", "  *  \n(###)\n . . "]
		},
		{
			"id": "golem",
			"name": "Rust Golem",
			"hp": 32,
			"attack": 4,
			"defense": 4,
			"speed": 2,
			"tech": 1,
			"xp": 19,
			"credits": 14,
			"frames": ["[===]\n |#|\n/_ _\\", "[===]\n \\#//\n/_ _\\"]
		}
	]

static func for_level(level: int) -> Dictionary:
	var base_list: Array[Dictionary] = all_enemies()
	var base: Dictionary = base_list[randi() % base_list.size()].duplicate(true)
	var scale: float = 1.0 + float(level - 1) * 0.18
	base.hp = int(base.hp * scale + randi_range(0, 6))
	base.attack = int(base.attack * scale + randi_range(0, 2))
	base.defense = int(base.defense * scale + randi_range(0, 2))
	base.speed = int(base.speed * scale)
	base.tech = int(base.tech * scale)
	base.xp = int(base.xp * scale)
	base.credits = int(base.credits * scale)
	return base
