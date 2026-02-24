extends PanelContainer
class_name CardView

signal drag_released(card_id: String, global_pos: Vector2)

@onready var title_label: Label = $VBox/Title
@onready var type_label: Label = $VBox/Type
@onready var cost_label: Label = $VBox/Cost
@onready var desc_label: Label = $VBox/Desc
@onready var art_label: RichTextLabel = $VBox/Art

var card_id := ""
var dragging := false
var drag_offset := Vector2.ZERO
var start_pos := Vector2.ZERO

func _ready() -> void:
	mouse_entered.connect(_mouse_entered)
	mouse_exited.connect(_mouse_exited)

func setup(data: Dictionary) -> void:
	card_id = data.id
	title_label.text = data.name
	type_label.text = data.cyber_type
	cost_label.text = str(data.cost)
	desc_label.text = data.description
	art_label.text = "\n".join(data.ascii_art_lines)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
			start_pos = position
			z_index = 99
			scale = Vector2(1.05, 1.05)
		else:
			if dragging:
				dragging = false
				scale = Vector2.ONE
				z_index = 0
				emit_signal("drag_released", card_id, get_global_mouse_position())
	elif event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset

func _mouse_entered() -> void:
	modulate = Color(1.1, 1.1, 1.1)

func _mouse_exited() -> void:
	modulate = Color(1, 1, 1)

func snap_to(target_pos: Vector2, rot: float) -> void:
	var tw := create_tween()
	tw.tween_property(self, "position", target_pos, 0.15)
	tw.parallel().tween_property(self, "rotation", rot, 0.15)
