extends Control

func _on_main_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_hub_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Hub.tscn")

func _on_deck_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/DeckBuilder.tscn")

func _on_run_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Run.tscn")

func _on_combat_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Combat.tscn")

func _on_card_sandbox_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/tests/CardSandbox.tscn")
