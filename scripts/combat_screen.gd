extends Control

signal request_run
signal request_hub

const CombatSystem = preload("res://scripts/systems/combat_system.gd")
const SynergySystem = preload("res://scripts/systems/synergy_system.gd")
const EnemiesContent = preload("res://scripts/content/enemies.gd")
const CardsContent = preload("res://scripts/content/cards.gd")

@export var enemy_id := "sentinel"

@onready var enemy_label: RichTextLabel = $EnemyPanel/EnemyVBox/EnemyAscii
@onready var enemy_stats: Label = $EnemyPanel/EnemyVBox/EnemyStats
@onready var player_stats: Label = $PlayerStats
@onready var combat_log: RichTextLabel = $CombatLog
@onready var hand: Control = $CardHand
@onready var drop_zone: Control = $PlayArea
@onready var end_turn_btn: Button = $EndTurnButton

var battle: Dictionary
var enemy_frames: Array = []
var frame_idx := 0

func _ready() -> void:
	var enemy := _get_enemy(enemy_id)
	var synergy := SynergySystem.analyze(GameState.save.player.deck)
	battle = CombatSystem.start_battle(GameState.save.player, enemy, synergy, GameState.rng)
	CombatSystem.refresh_turn(battle, GameState.save.player)
	enemy_frames = enemy.frames
	for n in hand.get_children():
		n.queue_free()
	if hand.has_method("set_drop_zone"):
		hand.set_drop_zone(drop_zone)
	if hand.has_method("set_card_map"):
		hand.set_card_map(CardsContent.by_id_map())
	hand.card_play_requested.connect(_on_card_play_requested)
	_refresh_ui()
	$AnimTimer.start(0.2)

func _get_enemy(id: String) -> Dictionary:
	for e in EnemiesContent.all_enemies():
		if e.id == id:
			return e
	return EnemiesContent.all_enemies()[0]

func _refresh_ui() -> void:
	enemy_label.text = enemy_frames[frame_idx]
	enemy_stats.text = "%s HP: %d" % [battle.enemy.name, battle.enemy_hp]
	var p: Dictionary = GameState.save.player
	player_stats.text = "HP %d/%d  Block %d  Mana %d" % [p.current_hp, p.stats.max_hp, battle.block, battle.mana]
	combat_log.text = "\n".join(battle.log.slice(max(0, battle.log.size() - 8), battle.log.size()))
	if hand.has_method("set_hand"):
		hand.set_hand(battle.hand)

func _on_card_play_requested(card_id: String) -> void:
	var res := CombatSystem.play_card(battle, GameState.save.player, card_id)
	if res != "ok":
		battle.log.append(res)
	else:
		battle.hand.erase(card_id)
	_check_battle_end()
	_refresh_ui()

func _on_end_turn_button_pressed() -> void:
	CombatSystem.cleanup_hand_to_discard(battle)
	CombatSystem.enemy_turn(battle, GameState.save.player)
	if _check_battle_end():
		return
	CombatSystem.refresh_turn(battle, GameState.save.player)
	_refresh_ui()

func _check_battle_end() -> bool:
	if battle.enemy_hp <= 0:
		GameState.grant_xp(15)
		battle.log.append("Victory!")
		GameState.save_game("Combat won")
		emit_signal("request_run")
		return true
	if GameState.save.player.current_hp <= 0:
		GameState.save.player.current_hp = GameState.save.player.stats.max_hp
		GameState.save.run.active = false
		GameState.save_game("Defeat")
		emit_signal("request_hub")
		return true
	return false

func _on_anim_timer_timeout() -> void:
	if enemy_frames.is_empty():
		return
	frame_idx = (frame_idx + 1) % enemy_frames.size()
	enemy_label.text = enemy_frames[frame_idx]

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("combat_end_turn"):
		_on_end_turn_button_pressed()
	for i in 5:
		if event.is_action_pressed("combat_card_%d" % [i + 1]) and i < battle.hand.size():
			_on_card_play_requested(battle.hand[i])
