extends RefCounted
class_name ExplorationSystem

static func generate_map(width: int, height: int, rng: RandomNumberGenerator) -> Array:
	var grid := []
	for y in height:
		var row := []
		for x in width:
			var c := "."
			if x == 0 or y == 0 or x == width - 1 or y == height - 1:
				c = "#"
			row.append(c)
		grid.append(row)
	_place(grid, width, height, rng, "E", 7)
	_place(grid, width, height, rng, "T", 5)
	_place(grid, width, height, rng, "X", 1)
	grid[1][1] = "P"
	return grid

static func _place(grid: Array, w: int, h: int, rng: RandomNumberGenerator, ch: String, count: int) -> void:
	var placed := 0
	while placed < count:
		var x := rng.randi_range(1, w - 2)
		var y := rng.randi_range(1, h - 2)
		if grid[y][x] == ".":
			grid[y][x] = ch
			placed += 1

static func map_to_text(grid: Array) -> String:
	var lines := PackedStringArray()
	for row in grid:
		lines.append("".join(row))
	return "\n".join(lines)
