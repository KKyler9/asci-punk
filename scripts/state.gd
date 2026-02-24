extends Node

const Models = preload("res://scripts/models.gd")
const Persistence = preload("res://scripts/persistence.gd")
const CardsContent = preload("res://scripts/content/cards.gd")

signal save_state_changed(text: String)
signal leveled_up

var save: Dictionary = {}
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	load_or_create()

func load_or_create() -> void:
	var loaded := Persistence.load_data()
	if loaded.is_empty():
		save = {
			"player": Models.default_player(),
			"run": Models.default_run_state(),
			"settings": Models.default_settings()
		}
	else:
		save = loaded
		if not save.has("settings"):
			save["settings"] = Models.default_settings()
		if not save.has("run"):
			save["run"] = Models.default_run_state()
	_apply_rng_settings()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game("Saved on quit")

func _apply_rng_settings() -> void:
	var settings: Dictionary = save.settings
	if settings.deterministic_rng:
		rng.seed = int(settings.debug_seed)
	else:
		rng.randomize()

func save_game(msg := "Saved") -> void:
	Persistence.save_data(save)
	emit_signal("save_state_changed", msg)

func ensure_account(handle: String, rig: String) -> void:
	var player: Dictionary = save.player
	if player.handle != "":
		return
	player.handle = handle.strip_edges()
	if player.handle == "":
		player.handle = "anon_runner"
	player.rig = rig
	player.deck = CardsContent.starter_deck_for_rig(rig)
	for card_id in player.deck:
		player.collection[card_id] = int(player.collection.get(card_id, 0)) + 1
	save_game("Account created")

func grant_xp(amount: int) -> void:
	var p: Dictionary = save.player
	p.xp += amount
	while p.xp >= p.next_xp:
		p.xp -= p.next_xp
		p.level += 1
		p.next_xp = int(round(p.next_xp * 1.35))
		p.pending_stat_points += 1
		if p.level == 10 and p.class == "":
			p.pending_class_choice = true
		if p.level > 10 and p.level % 5 == 0:
			p.pending_perk_choices += 1
		if p.level % 3 == 0:
			p.cyber_capacity += 1
		emit_signal("leveled_up")
	save_game("XP updated")

func apply_stat_choice(stat_key: String) -> void:
	var p: Dictionary = save.player
	if p.pending_stat_points <= 0:
		return
	if p.stats.has(stat_key):
		p.stats[stat_key] += 1
		if stat_key == "max_hp":
			p.current_hp += 5
	p.pending_stat_points -= 1
	save_game("Stat upgraded")

func choose_class(chosen_class: String) -> void:
	var p: Dictionary = save.player
	if not p.pending_class_choice:
		return
	p.class = chosen_class
	p.pending_class_choice = false
	if chosen_class == "Cracker":
		p.stats.magic += 2
	elif chosen_class == "Bulwark":
		p.stats.max_hp += 10
		p.current_hp += 10
	elif chosen_class == "Proxy":
		p.stats.intelligence += 2
	save_game("Class chosen")

func choose_perk(chosen_perk: String) -> void:
	var p: Dictionary = save.player
	if p.pending_perk_choices <= 0:
		return
	if not p.perks.has(chosen_perk):
		p.perks.append(chosen_perk)
		if chosen_perk == "Deep Cache":
			p.cyber_capacity += 2
		elif chosen_perk == "Adrenal Compiler":
			p.stats.attack += 1
		elif chosen_perk == "Quantum Mind":
			p.stats.intelligence += 1
		p.pending_perk_choices -= 1
	save_game("Perk chosen")
