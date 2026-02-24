extends Control
class_name DropZone

func accepts(global_pos: Vector2) -> bool:
	return get_global_rect().has_point(global_pos)
