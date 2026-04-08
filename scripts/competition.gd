extends Control

const COMP_SYS = preload("res://scripts/systems/competition_system.gd")

@onready var output: RichTextLabel = $MarginContainer/VBoxContainer/Output
@onready var marker: ColorRect = $MarginContainer/VBoxContainer/QTE/Track/Marker
@onready var zone: ColorRect = $MarginContainer/VBoxContainer/QTE/Track/Zone

var t: float = 0.0
var dir: float = 1.0
var qte_bonus: float = 0.0

func _process(delta: float) -> void:
	t += delta * 1.6 * dir
	if t >= 1.0:
		t = 1.0
		dir = -1.0
	elif t <= 0.0:
		t = 0.0
		dir = 1.0
	marker.position.x = lerpf(0, 300, t)
	if Input.is_action_just_pressed("ui_accept"):
		_on_tap_pressed()

func _on_tap_pressed() -> void:
	var d: float = absf(marker.position.x - (zone.position.x + zone.size.x * 0.5))
	qte_bonus = clampf(0.25 - d / 240.0, 0.0, 0.25)
	output.text = "Reaction bonus locked: +%d%%" % int(qte_bonus * 100)

func _on_run_pressed() -> void:
	var stats: Dictionary = GameState.get_pet_stats()
	var player_score: float = COMP_SYS.score_pet(stats, qte_bonus)
	var opps: Array = COMP_SYS.generate_opponents(player_score)
	var board: Array = [{"name": GameState.save.profile.name, "score": player_score}]
	for o in opps:
		board.append({"name": o.name, "score": o.power})
	board.sort_custom(func(a, b): return a.score > b.score)
	var rank: int = 1
	for i in board.size():
		if board[i].name == GameState.save.profile.name:
			rank = i + 1
			break
	var reward: int = maxi(12, 50 - rank * 4)
	GameState.save.inventory.credits += reward
	GameState.save.week.last_competition = Time.get_unix_time_from_system()
	GameState.save.competition.last_rank = rank
	GameState.save.competition.last_score = player_score
	GameState.save_game()
	output.text = "Weekly Gauntlet Results\nRank #%d / %d\nReward: %d credits\n\nLeaderboard:\n" % [rank, board.size(), reward]
	for entry in board:
		output.append_text("%s : %.1f\n" % [entry.name, entry.score])

func _on_back_pressed() -> void:
	GameState.request_scene("home")
