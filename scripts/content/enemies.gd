extends RefCounted
class_name EnemyData

static func for_level(level: int) -> Dictionary:
	var names := ["Scrap Drone", "Null Rat", "Firewall Wisp", "Rust Golem", "Proxy Fang"]
	var idx := randi() % names.size()
	var scale := 1.0 + float(level - 1) * 0.18
	return {
		"name": names[idx],
		"hp": int(24 * scale + randi_range(0, 8)),
		"attack": int(4 * scale + randi_range(0, 3)),
		"defense": int(2 * scale + randi_range(0, 2)),
		"speed": int(3 * scale + randi_range(0, 3)),
		"tech": int(2 * scale + randi_range(0, 3)),
		"xp": int(16 * scale),
		"credits": int(12 * scale)
	}
