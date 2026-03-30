extends Control

@onready var status_label: Label = $MarginContainer/VBoxContainer/Status
@onready var timer_label: Label = $MarginContainer/VBoxContainer/Timer

func _ready() -> void:
	GameState.data_changed.connect(refresh)
	refresh()

func _process(_delta: float) -> void:
	if GameState.save.activity.active:
		timer_label.text = "Time left: %.1fs" % maxf(0.0, GameState.save.activity.end_time - Time.get_unix_time_from_system())

func refresh() -> void:
	if GameState.save.activity.active:
		status_label.text = "Activity active: %s" % GameState.save.activity.kind
	else:
		status_label.text = "Idle"

func _on_scavenge_pressed() -> void: GameState.start_activity("scavenge")
func _on_recovery_pressed() -> void: GameState.start_activity("recovery")
func _on_collect_pressed() -> void: GameState.collect_activity()
func _on_back_pressed() -> void: GameState.request_scene("home")
