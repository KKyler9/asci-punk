extends RefCounted
class_name ExplorationSystem

const WIDTH := 20
const HEIGHT := 12

static func create_run(level: int) -> Dictionary:
	var tiles := []
	for y in HEIGHT:
		var row := []
		for x in WIDTH:
			row.append(".")
		tiles.append(row)
	var run := {
		"width": WIDTH,
		"height": HEIGHT,
		"tiles": tiles,
		"player": Vector2i(0, 0),
		"exit": Vector2i(WIDTH - 1, HEIGHT - 1),
		"enemies": [],
		"loot": [],
		"events": [],
		"visited": {},
		"rewards": {"xp": 0, "credits": 0, "materials": 0}
	}
	for i in 6:
		run.enemies.append(Vector2i(randi_range(2, WIDTH - 2), randi_range(1, HEIGHT - 2)))
	for i in 5:
		run.loot.append(Vector2i(randi_range(1, WIDTH - 2), randi_range(1, HEIGHT - 2)))
	for i in 4:
		run.events.append(Vector2i(randi_range(1, WIDTH - 2), randi_range(1, HEIGHT - 2)))
	return run

static func move_player(run: Dictionary, dir: Vector2i) -> void:
	var p: Vector2i = run.player
	p += dir
	p.x = clampi(p.x, 0, run.width - 1)
	p.y = clampi(p.y, 0, run.height - 1)
	run.player = p
