extends Control

const CardsContent = preload("res://scripts/content/cards.gd")

@onready var hand: CardHand = $CardHand
@onready var zone: DropZone = $PlayArea
@onready var info: Label = $Info

func _ready() -> void:
	hand.set_drop_zone(zone)
	hand.set_card_map(CardsContent.by_id_map())
	hand.card_play_requested.connect(_on_card_play_requested)
	hand.set_hand(["red_slash", "guard_matrix", "ping_spike", "packet_sniff", "reboot"])
	info.text = "Drag cards into PLAY AREA to verify drag/drop + fan + tilt."

func _on_card_play_requested(card_id: String) -> void:
	info.text = "Played from sandbox: %s" % card_id

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tests/TestMenu.tscn")
