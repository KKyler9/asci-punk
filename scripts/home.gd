extends Control

@onready var pet_display = $MarginContainer/VBoxContainer/TopRow/PetDisplay
@onready var stats_label: Label = $MarginContainer/VBoxContainer/TopRow/StatsPanel/StatsLabel
@onready var progress: ProgressBar = $MarginContainer/VBoxContainer/TopRow/StatsPanel/XPBar
@onready var mood_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/StatsPanel/MoodBar
@onready var energy_bar: ProgressBar = $MarginContainer/VBoxContainer/TopRow/StatsPanel/EnergyBar
@onready var prestige_btn: Button = $MarginContainer/VBoxContainer/ButtonsRow/PrestigeButton
@onready var fragments_label: Label = $MarginContainer/VBoxContainer/MetaPanel/FragmentsLabel
@onready var upgrades_box: VBoxContainer = $MarginContainer/VBoxContainer/MetaPanel/Upgrades

func _ready() -> void:
	GameState.data_changed.connect(refresh)
	refresh()

func refresh() -> void:
	if not GameState.save.initialized:
		return
	var stats := GameState.get_pet_stats()
	var pet := GameState.save.pet
	pet_display.call("set_pet", pet)
	stats_label.text = "Lv.%d %s\nHP %d  ATK %d  DEF %d\nSPD %d  TECH %d  EN %d  LUCK %d\nCredits: %d  Materials: %d" % [
		pet.level, pet.name, stats.hp, stats.attack, stats.defense, stats.speed, stats.tech, stats.energy, stats.luck, GameState.save.inventory.credits, GameState.save.inventory.materials
	]
	progress.max_value = preload("res://scripts/models.gd").xp_to_next(pet.level)
	progress.value = pet.xp
	mood_bar.value = pet.mood
	energy_bar.max_value = stats.energy
	energy_bar.value = pet.energy_current
	prestige_btn.visible = GameState.can_prestige()
	fragments_label.text = "Core Fragments: %d | Prestiges: %d" % [GameState.save.core_fragments, GameState.save.prestige_count]
	for c in upgrades_box.get_children():
		c.queue_free()
	for key in GameState.save.meta_upgrades.keys():
		var up = GameState.save.meta_upgrades[key]
		var btn := Button.new()
		btn.text = "%s Lv%d/%d (Cost %d)" % [up.name, up.level, up.max, GameState.upgrade_cost(key)]
		btn.disabled = up.level >= up.max
		btn.pressed.connect(func() -> void: GameState.buy_meta_upgrade(key))
		upgrades_box.add_child(btn)

func _on_train_pressed() -> void: GameState.request_scene("training")
func _on_activities_pressed() -> void: GameState.request_scene("activities")
func _on_explore_pressed() -> void:
	GameState.start_exploration()
	GameState.request_scene("explore")
func _on_gear_pressed() -> void: GameState.request_scene("gear")
func _on_competition_pressed() -> void: GameState.request_scene("competition")
func _on_save_pressed() -> void:
	GameState.save_game()
	GameState.save.settings.crt_enabled = not GameState.save.settings.crt_enabled
	GameState.save_game()
	GameState.data_changed.emit()
func _on_prestige_button_pressed() -> void: GameState.do_prestige()
