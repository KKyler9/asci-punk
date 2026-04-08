extends Control

signal battle_finished(victory: bool, reward: Dictionary)

const COMBAT_SYS = preload("res://scripts/systems/combat_system.gd")

@onready var log_label: RichTextLabel = $MarginContainer/VBoxContainer/Log
@onready var player_hp: ProgressBar = $MarginContainer/VBoxContainer/Bars/PlayerHP
@onready var enemy_hp: ProgressBar = $MarginContainer/VBoxContainer/Bars/EnemyHP

var pet_stats: Dictionary
var enemy: Dictionary
var temp_def := 0
var buff_attack := 0

func setup_battle(enemy_data: Dictionary) -> void:
	enemy = enemy_data.duplicate(true)
	pet_stats = GameState.get_pet_stats()
	player_hp.max_value = pet_stats.hp
	player_hp.value = GameState.save.pet.hp_current
	enemy_hp.max_value = enemy.hp
	enemy_hp.value = enemy.hp
	_log("Encounter: %s" % enemy.name)

func _ready() -> void:
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("combat_card_1"):
		_on_attack_pressed()
	elif event.is_action_pressed("combat_card_2"):
		_on_defend_pressed()
	elif event.is_action_pressed("combat_card_3"):
		_on_ability_pressed()

func _on_attack_pressed() -> void:
	var dmg := COMBAT_SYS.damage(pet_stats.attack + buff_attack, enemy.defense)
	enemy_hp.value -= dmg
	_log("You hit for %d" % dmg)
	_check_end_or_enemy_turn()

func _on_defend_pressed() -> void:
	temp_def = 4 + int(pet_stats.defense * 0.35)
	_log("Defensive posture")
	enemy_turn()

func _on_ability_pressed() -> void:
	if GameState.save.installed_implants.is_empty():
		_log("No implant ability equipped")
		return
	var id: String = str(GameState.save.installed_implants[0])
	var impl: Dictionary = preload("res://scripts/content/implant_data.gd").all()[id]
	if GameState.save.pet.energy_current < impl.energy_cost:
		_log("Insufficient energy")
		return
	GameState.save.pet.energy_current -= impl.energy_cost
	match id:
		"shock_pulse":
			var dmg := COMBAT_SYS.damage(pet_stats.tech + 6, enemy.defense, 1)
			enemy_hp.value -= dmg
			_log("Shock Pulse %d" % dmg)
		"reactive_shield":
			temp_def += 7
			_log("Reactive Shield engaged")
		"overclock":
			buff_attack += 3
			_log("Overclock online")
		"nano_heal":
			player_hp.value = mini(player_hp.max_value, player_hp.value + 14 + pet_stats.tech)
			_log("Nano Heal restored HP")
	_check_end_or_enemy_turn()

func enemy_turn() -> void:
	var dmg := COMBAT_SYS.damage(enemy.attack, pet_stats.defense + temp_def)
	temp_def = 0
	player_hp.value -= dmg
	_log("%s hits for %d" % [enemy.name, dmg])
	_check_end()

func _check_end_or_enemy_turn() -> void:
	if not _check_end():
		enemy_turn()

func _check_end() -> bool:
	if enemy_hp.value <= 0:
		GameState.save.pet.hp_current = int(player_hp.value)
		emit_signal("battle_finished", true, {"xp": enemy.xp, "credits": enemy.credits})
		queue_free()
		return true
	if player_hp.value <= 0:
		GameState.save.pet.hp_current = max(1, int(pet_stats.hp * 0.35))
		emit_signal("battle_finished", false, {})
		queue_free()
		return true
	return false

func _log(line: String) -> void:
	log_label.append_text(line + "\n")
