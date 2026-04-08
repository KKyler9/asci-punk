extends RefCounted
class_name ExplorationSystem

const WIDTH := 28
const HEIGHT := 16
const LIGHT_RADIUS := 2

static func create_run(level: int) -> Dictionary:
	var tiles := _generate_tiles(level)
	var run := {
		"width": WIDTH,
		"height": HEIGHT,
		"tiles": tiles,
		"player": Vector2i(1, 1),
		"exit": Vector2i(WIDTH - 2, HEIGHT - 2),
		"enemies": [],
		"loot": [],
		"events": [],
		"visited": {},
		"light_radius": LIGHT_RADIUS,
		"rewards": {"xp": 0, "credits": 0, "materials": 0}
	}

	# Guarantee spawn/exit are walkable.
	run.tiles[run.player.y][run.player.x] = "."
	run.tiles[run.exit.y][run.exit.x] = "."

	_reveal_around(run)
	_place_encounters(run, level)
	return run

static func move_player(run: Dictionary, dir: Vector2i) -> bool:
	var next := run.player + dir
	next.x = clampi(next.x, 0, run.width - 1)
	next.y = clampi(next.y, 0, run.height - 1)
	if next == run.player:
		return false
	if not _is_walkable(run.tiles[next.y][next.x]):
		return false
	run.player = next
	_reveal_around(run)
	return true

static func _generate_tiles(level: int) -> Array:
	var tiles: Array = []
	for y in HEIGHT:
		var row: Array = []
		for x in WIDTH:
			if x == 0 or y == 0 or x == WIDTH - 1 or y == HEIGHT - 1:
				row.append("#")
			elif randf() < 0.37:
				row.append("#")
			else:
				row.append(_pick_terrain())
		tiles.append(row)

	# Carve a guaranteed traversable spine from spawn to exit.
	var cursor := Vector2i(1, 1)
	while cursor.x < WIDTH - 2 or cursor.y < HEIGHT - 2:
		tiles[cursor.y][cursor.x] = "."
		if cursor.x < WIDTH - 2 and (cursor.y >= HEIGHT - 2 or randf() < 0.58):
			cursor.x += 1
		elif cursor.y < HEIGHT - 2:
			cursor.y += 1
		tiles[cursor.y][cursor.x] = "."

	# Carve branch rooms and corridors for replay variety.
	var extra_carves := 42 + level * 2
	for _i in extra_carves:
		var p := Vector2i(randi_range(1, WIDTH - 2), randi_range(1, HEIGHT - 2))
		var steps := randi_range(4, 12)
		for _s in steps:
			tiles[p.y][p.x] = _pick_terrain()
			var dir := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN][randi() % 4]
			p += dir
			p.x = clampi(p.x, 1, WIDTH - 2)
			p.y = clampi(p.y, 1, HEIGHT - 2)

	return tiles

static func _place_encounters(run: Dictionary, level: int) -> void:
	var floor_cells := []
	for y in run.height:
		for x in run.width:
			var pos := Vector2i(x, y)
			if pos == run.player or pos == run.exit:
				continue
			if _is_walkable(run.tiles[y][x]):
				floor_cells.append(pos)

	if floor_cells.is_empty():
		return

	var used := {}
	var enemy_count := mini(floor_cells.size() / 5, 7 + level / 3)
	var loot_count := mini(floor_cells.size() / 7, 5 + level / 4)
	var event_count := mini(floor_cells.size() / 8, 4 + level / 5)

	for _i in enemy_count:
		var pos := _unique_pick(floor_cells, used)
		if pos != Vector2i(-1, -1):
			run.enemies.append(pos)
	for _i in loot_count:
		var pos := _unique_pick(floor_cells, used)
		if pos != Vector2i(-1, -1):
			run.loot.append(pos)
	for _i in event_count:
		var pos := _unique_pick(floor_cells, used)
		if pos != Vector2i(-1, -1):
			run.events.append(pos)

static func _unique_pick(pool: Array, used: Dictionary) -> Vector2i:
	if pool.is_empty():
		return Vector2i(-1, -1)
	for _i in 32:
		var pos: Vector2i = pool[randi() % pool.size()]
		if not used.has(pos):
			used[pos] = true
			return pos
	return Vector2i(-1, -1)

static func _reveal_around(run: Dictionary) -> void:
	var r: int = int(run.get("light_radius", LIGHT_RADIUS))
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if abs(dx) + abs(dy) > r + 1:
				continue
			var pos := Vector2i(run.player.x + dx, run.player.y + dy)
			if pos.x < 0 or pos.y < 0 or pos.x >= run.width or pos.y >= run.height:
				continue
			run.visited[pos] = true

static func _is_walkable(tile: String) -> bool:
	return tile != "#"

static func _pick_terrain() -> String:
	var roll := randf()
	if roll < 0.55:
		return "."
	if roll < 0.8:
		return ","
	return ";"
