extends Control

const SCENES := {
	"home": preload("res://scenes/Home.tscn"),
	"training": preload("res://scenes/Training.tscn"),
	"activities": preload("res://scenes/Activities.tscn"),
	"explore": preload("res://scenes/Explore.tscn"),
	"gear": preload("res://scenes/Gear.tscn"),
	"competition": preload("res://scenes/Competition.tscn")
}

@onready var view_root: Control = $MarginContainer/ViewRoot
@onready var crt_overlay: CanvasLayer = $CRTOverlay
@onready var setup_panel: Panel = $SetupPanel
@onready var name_edit: LineEdit = $SetupPanel/VBoxContainer/NameEdit
@onready var starters_box: HBoxContainer = $SetupPanel/VBoxContainer/StarterButtons

var current_view: Control
var starter_id: String = "aggressive"

func _ready() -> void:
	GameState.scene_requested.connect(_on_scene_requested)
	GameState.combat_requested.connect(_on_combat_requested)
	_build_starters()
	if GameState.save.initialized:
		setup_panel.hide()
		_open_view("home")
	else:
		setup_panel.show()
	_apply_settings()
	GameState.data_changed.connect(_apply_settings)

func _build_starters() -> void:
	for c in starters_box.get_children():
		c.queue_free()
	for starter in preload("res://scripts/content/pets.gd").starters():
		var b: Button = Button.new()
		b.text = starter.name
		b.pressed.connect(func() -> void: starter_id = starter.id)
		starters_box.add_child(b)

func _on_start_pressed() -> void:
	var pname: String = name_edit.text.strip_edges()
	if pname == "":
		pname = "Operator"
	GameState.create_new_profile(pname, starter_id)
	setup_panel.hide()
	_open_view("home")

func _open_view(name: String) -> void:
	if current_view:
		current_view.queue_free()
	current_view = SCENES[name].instantiate()
	view_root.add_child(current_view)

func _on_scene_requested(name: String) -> void:
	if SCENES.has(name):
		_open_view(name)

func _on_combat_requested(enemy: Dictionary) -> void:
	_open_view("explore")
	var ex: Control = current_view
	if ex.has_method("open_combat"):
		ex.open_combat(enemy)

func _on_back_home_pressed() -> void:
	_open_view("home")

func _apply_settings() -> void:
	crt_overlay.visible = GameState.save.settings.crt_enabled
