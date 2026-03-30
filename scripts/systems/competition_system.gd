extends RefCounted
class_name CompetitionSystem

static func generate_opponents(player_power: float, count := 8) -> Array:
	var out := []
	for i in count:
		var scale := randf_range(0.8, 1.25)
		out.append({
			"name": "Runner-%02d" % (i + 1),
			"power": player_power * scale + randf_range(-6.0, 10.0)
		})
	return out

static func score_pet(stats: Dictionary, qte_bonus: float) -> float:
	var base := stats.attack * 1.4 + stats.defense * 1.2 + stats.speed * 1.1 + stats.tech * 1.2 + stats.hp * 0.35 + stats.luck * 0.8
	return base * (1.0 + qte_bonus) + randf_range(-8.0, 8.0)
