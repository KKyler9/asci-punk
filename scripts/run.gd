extends Control

signal request_hub
signal request_combat(enemy_id: String)

const ExplorationSystem = preload("res://scripts/systems/exploration_system.gd")
const CardsContent = preload("res://scripts/content/cards.gd")
const EnemiesContent = preload("res://scripts/content/enemies.gd")

@onready var map_view: RichTextLabel = $Outer/MapPanel/MapView
@onready var log_label: Label = $Outer/LogLabel
@onready var reward_panel: PanelContainer = $RewardPanel
@onready var reward_buttons: HBoxContainer = $RewardPanel/RewardButtons

var run_state: Dictionary

func _ready() -> void:
	run_state = GameState.save.run
	if not bool(run_state.active):
		run_state.active = true
		run_state.grid = ExplorationSystem.generate_map(20, 12, GameState.rng)
		run_state.player_pos = {"x":1,"y":1}
	_refresh_map()

func _refresh_map() -> void:
	map_view.text = ExplorationSystem.map_to_text(run_state.grid)

func _input(event: InputEvent) -> void:
	if reward_panel.visible:
		return
	var delta := Vector2i.ZERO
	if event.is_action_pressed("move_up"):
		delta = Vector2i(0, -1)
	elif event.is_action_pressed("move_down"):
		delta = Vector2i(0, 1)
	elif event.is_action_pressed("move_left"):
		delta = Vector2i(-1, 0)
	elif event.is_action_pressed("move_right"):
		delta = Vector2i(1, 0)
	if delta != Vector2i.ZERO:
		_move(delta)

func _move(delta: Vector2i) -> void:
	var p: Dictionary = run_state.player_pos
	var nx: int = int(p.x) + delta.x
	var ny: int = int(p.y) + delta.y
	if run_state.grid[ny][nx] == "#":
		return
	run_state.grid[p.y][p.x] = "."
	var tile: String = run_state.grid[ny][nx]
	run_state.player_pos = {"x":nx,"y":ny}
	run_state.grid[ny][nx] = "P"
	_refresh_map()
	match tile:
		"E":
			var enemies := EnemiesContent.all_enemies()
			var picked = enemies[GameState.rng.randi_range(0, enemies.size() - 1)]
			GameState.save.run = run_state
			emit_signal("request_combat", String(picked.id))
		"T":
			_show_card_reward()
		"X":
			run_state.active = false
			GameState.grant_xp(20)
			GameState.save_game("Run complete")
			emit_signal("request_hub")

func _show_card_reward() -> void:
	reward_panel.visible = true
	for c in reward_buttons.get_children():
		c.queue_free()
	var all := CardsContent.all_cards()
	for _i in 3:
		var card: Dictionary = all[GameState.rng.randi_range(0, all.size() - 1)]
		var btn := Button.new()
		btn.text = "%s\n[%s]" % [card.name, card.cyber_type]
		btn.custom_minimum_size = Vector2(180, 64)
		btn.pressed.connect(func(): _pick_reward(card.id))
		reward_buttons.add_child(btn)
	log_label.text = "Treasure cache cracked: choose one card"

func _pick_reward(card_id: String) -> void:
	var p: Dictionary = GameState.save.player
	p.collection[card_id] = int(p.collection.get(card_id, 0)) + 1
	if p.deck.size() < p.cyber_capacity:
		p.deck.append(card_id)
	reward_panel.visible = false
	GameState.save_game("Card rewarded")

func _on_leave_pressed() -> void:
	run_state.active = false
	GameState.save.run = run_state
	GameState.save_game("Run aborted")
	emit_signal("request_hub")
