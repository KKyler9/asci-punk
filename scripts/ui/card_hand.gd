extends Control
class_name CardHand

signal card_play_requested(card_id: String)

const CardViewScene = preload("res://scenes/ui/CardView.tscn")

var hand_ids: Array = []
var card_map: Dictionary = {}
var drop_zone: Node

func set_card_map(map: Dictionary) -> void:
	card_map = map

func set_drop_zone(zone: Node) -> void:
	drop_zone = zone

func set_hand(ids: Array) -> void:
	hand_ids = ids.duplicate()
	for c in get_children():
		c.queue_free()
	for id in hand_ids:
		if not card_map.has(id):
			continue
		var view: CardView = CardViewScene.instantiate()
		add_child(view)
		view.setup(card_map[id])
		view.drag_released.connect(_on_card_drag_released)
	await get_tree().process_frame
	_layout_fan()

func _layout_fan() -> void:
	var n := get_child_count()
	if n == 0:
		return
	var center := size.x * 0.5
	var spread := min(40.0, 260.0 / max(1, n - 1))
	for i in n:
		var card := get_child(i)
		var offset := (i - (n - 1) / 2.0) * spread
		var angle_deg := (i - (n - 1) / 2.0) * 6.0
		var y_arc := abs(offset) * 0.12
		card.snap_to(Vector2(center + offset - 90, 10 + y_arc), deg_to_rad(angle_deg))

func _on_card_drag_released(card_id: String, global_pos: Vector2) -> void:
	if drop_zone != null and drop_zone.has_method("accepts") and drop_zone.accepts(global_pos):
		emit_signal("card_play_requested", card_id)
	_layout_fan()
