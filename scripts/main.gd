extends Control

@onready var layer: Control = $ScreenLayer
@onready var save_label: Label = $SaveLabel
@onready var crt_overlay: CanvasItem = $CRTOverlay

const HUB_SCENE = preload("res://scenes/Hub.tscn")
const RUN_SCENE = preload("res://scenes/Run.tscn")
const COMBAT_SCENE = preload("res://scenes/Combat.tscn")
const DECK_SCENE = preload("res://scenes/DeckBuilder.tscn")

func _ready() -> void:
	GameState.save_state_changed.connect(_on_save_state)
	_show_hub()
	_apply_crt_enabled()

func _on_save_state(msg: String) -> void:
	save_label.text = msg
	var t := create_tween()
	save_label.modulate.a = 1.0
	t.tween_property(save_label, "modulate:a", 0.2, 1.0)

func _clear_screen() -> void:
	for c in layer.get_children():
		c.queue_free()

func _show_scene(scene: PackedScene) -> Node:
	_clear_screen()
	var node := scene.instantiate()
	layer.add_child(node)
	return node

func _show_hub() -> void:
	var hub = _show_scene(HUB_SCENE)
	hub.request_run.connect(_show_run)
	hub.request_deck_builder.connect(_show_deck)
	hub.request_crt_toggle.connect(_on_crt_toggle)

func _show_deck() -> void:
	var deck = _show_scene(DECK_SCENE)
	deck.request_back.connect(_show_hub)
	deck.request_run.connect(_show_run)

func _show_run() -> void:
	var run = _show_scene(RUN_SCENE)
	run.request_hub.connect(_show_hub)
	run.request_combat.connect(_show_combat)

func _show_combat(enemy_id: String) -> void:
	var combat = _show_scene(COMBAT_SCENE)
	combat.enemy_id = enemy_id
	combat.request_hub.connect(_show_hub)
	combat.request_run.connect(_show_run)

func _on_crt_toggle(enabled: bool) -> void:
	GameState.save.settings.crt_enabled = enabled
	_apply_crt_enabled()
	GameState.save_game("CRT toggled")

func _apply_crt_enabled() -> void:
	crt_overlay.visible = bool(GameState.save.settings.crt_enabled)
