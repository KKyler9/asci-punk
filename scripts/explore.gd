extends Control

const ENEMIES = preload("res://scripts/content/enemies.gd")
const EXP_SYS = preload("res://scripts/systems/exploration_system.gd")

@onready var map_label: Label = $MarginContainer/VBoxContainer/MapPanel/MapLabel
@onready var info_label: Label = $MarginContainer/VBoxContainer/Info
@onready var combat_layer: Control = $CombatLayer

var pending_enemy: Dictionary = {}

func _ready() -> void:
	refresh_map()

func _unhandled_input(event: InputEvent) -> void:
	if combat_layer.visible:
		return
	if event.is_action_pressed("move_up"):
		move(Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		move(Vector2i.DOWN)
	elif event.is_action_pressed("move_left"):
		move(Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		move(Vector2i.RIGHT)

func move(dir: Vector2i) -> void:
	if GameState.current_run.is_empty():
		return
	if not EXP_SYS.move_player(GameState.current_run, dir):
		info_label.text = "Blocked path (#). Find an opening."
		return
	resolve_tile()
	refresh_map()

func resolve_tile() -> void:
	var run: Dictionary = GameState.current_run
	var p: Vector2i = run.player
	if p == run.exit:
		GameState.add_xp(run.rewards.xp + 20)
		GameState.save.inventory.credits += run.rewards.credits + 20
		GameState.save.inventory.materials += run.rewards.materials + 8
		GameState.save_game()
		GameState.request_scene("home")
		return
	if run.enemies.has(p):
		run.enemies.erase(p)
		pending_enemy = ENEMIES.for_level(GameState.save.pet.level)
		open_combat(pending_enemy)
	elif run.loot.has(p):
		run.loot.erase(p)
		run.rewards.credits += randi_range(8, 22)
		run.rewards.materials += randi_range(3, 8)
		if randf() < 0.25:
			var gear_ids: Array = preload("res://scripts/content/gear_data.gd").all().keys()
			GameState.save.inventory.gear.append(gear_ids[randi() % gear_ids.size()])
		info_label.text = "Crate opened: loot acquired"
	elif run.events.has(p):
		run.events.erase(p)
		GameState.add_xp(10)
		if randf() < 0.4:
			GameState.save.pet.bonus_stats.luck += 1
		info_label.text = "Event node: data cache synced"

func refresh_map() -> void:
	var run: Dictionary = GameState.current_run
	if run.is_empty():
		map_label.text = "No run active"
		return
	var lines: Array[String] = []
	for y in run.height:
		var row: String = ""
		for x in run.width:
			var pos: Vector2i = Vector2i(x, y)
			var discovered: bool = bool(run.visited.has(pos))
			var in_light: bool = abs(pos.x - run.player.x) + abs(pos.y - run.player.y) <= int(run.get("light_radius", 2)) + 1
			if not discovered and not in_light:
				row += " "
				continue
			if pos == run.player:
				row += "@"
			elif pos == run.exit:
				row += "E"
			elif run.enemies.has(pos):
				row += "M"
			elif run.loot.has(pos):
				row += "$"
			elif run.events.has(pos):
				row += "?"
			else:
				row += run.tiles[y][x]
		lines.append(row)
	map_label.text = "\n".join(lines)
	if not info_label.text.begins_with("Blocked") and not info_label.text.begins_with("Enemy") and not info_label.text.begins_with("Crate") and not info_label.text.begins_with("Event"):
		info_label.text = "WASD/Arrows | @ You E Exit M Enemy $ Loot ? Event # Wall | XP:%d C:%d M:%d" % [run.rewards.xp, run.rewards.credits, run.rewards.materials]

func open_combat(enemy: Dictionary) -> void:
	combat_layer.visible = true
	var combat_scene: Control = preload("res://scenes/Combat.tscn").instantiate()
	combat_layer.add_child(combat_scene)
	combat_scene.call("setup_battle", enemy)
	combat_scene.connect("battle_finished", _on_battle_finished)

func _on_battle_finished(victory: bool, reward: Dictionary) -> void:
	for c in combat_layer.get_children():
		c.queue_free()
	combat_layer.visible = false
	if victory:
		GameState.current_run.rewards.xp += reward.xp
		GameState.current_run.rewards.credits += reward.credits
		info_label.text = "Enemy defeated"
	else:
		GameState.request_scene("home")

func _on_leave_pressed() -> void:
	GameState.request_scene("home")
