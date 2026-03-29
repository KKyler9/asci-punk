extends Control

@onready var status_label: Label = $MarginContainer/VBoxContainer/Status
@onready var timer_label: Label = $MarginContainer/VBoxContainer/Timer
@onready var marker: ColorRect = $MarginContainer/VBoxContainer/Minigame/Track/Marker
@onready var zone: ColorRect = $MarginContainer/VBoxContainer/Minigame/Track/Zone

var marker_t := 0.0
var marker_dir := 1.0

func _ready() -> void:
	GameState.data_changed.connect(refresh)
	refresh()

func _process(delta: float) -> void:
	marker_t += delta * 1.7 * marker_dir
	if marker_t >= 1.0:
		marker_t = 1.0
		marker_dir = -1.0
	elif marker_t <= 0.0:
		marker_t = 0.0
		marker_dir = 1.0
	marker.position.x = lerpf(0, 300, marker_t)
	if Input.is_action_just_pressed("ui_accept"):
		_on_tap_pressed()
	if GameState.save.training.active:
		timer_label.text = "Time left: %.1fs" % maxf(0.0, GameState.save.training.end_time - Time.get_unix_time_from_system())

func refresh() -> void:
	var t = GameState.save.training
	if t.active:
		status_label.text = "Training active: %s" % t.kind
	else:
		status_label.text = "Pick a training program"

func _on_strength_pressed() -> void: GameState.start_training("strength")
func _on_defense_pressed() -> void: GameState.start_training("defense")
func _on_tech_pressed() -> void: GameState.start_training("tech")
func _on_collect_pressed() -> void: GameState.collect_training()

func _on_tap_pressed() -> void:
	var mark_x := marker.position.x
	var zone_center := zone.position.x + zone.size.x * 0.5
	var d := absf(mark_x - zone_center)
	var quality := clampf(1.0 - (d / 80.0), 0.0, 1.0)
	GameState.apply_training_minigame(quality)

func _on_back_pressed() -> void:
	GameState.request_scene("home")
