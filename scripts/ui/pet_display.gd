extends Control

@onready var body: ColorRect = $Body
@onready var eye_l: ColorRect = $EyeL
@onready var eye_r: ColorRect = $EyeR

var base_y: float = 0.0
var t: float = 0.0

func _ready() -> void:
	base_y = body.position.y

func _process(delta: float) -> void:
	t += delta
	body.position.y = base_y + sin(t * 2.0) * 2.0
	var blink: bool = int(t * 2.3) % 7 == 0
	eye_l.visible = not blink
	eye_r.visible = not blink

func set_pet(pet: Dictionary) -> void:
	body.color = Color(pet.color)
