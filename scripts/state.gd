extends Node

signal data_changed
signal scene_requested(scene_name: String)
signal combat_requested(enemy: Dictionary)

const PETS = preload("res://scripts/content/pets.gd")
const GEAR = preload("res://scripts/content/gear_data.gd")
const IMPLANTS = preload("res://scripts/content/implant_data.gd")
const MODELS = preload("res://scripts/models.gd")
const PERSIST = preload("res://scripts/persistence.gd")
const TRAIN_SYS = preload("res://scripts/systems/training_system.gd")
const ACT_SYS = preload("res://scripts/systems/activity_system.gd")
const EXPLORE_SYS = preload("res://scripts/systems/exploration_system.gd")

var save: Dictionary = {}
var current_run: Dictionary = {}

func _ready() -> void:
	randomize()
	load_game()

func default_save() -> Dictionary:
	return {
		"initialized": false,
		"profile": {"name": "", "created_unix": Time.get_unix_time_from_system()},
		"pet": {},
		"inventory": MODELS.blank_inventory(),
		"equipped_gear": {"collar": "", "plating": "", "booster": "", "trinket": ""},
		"installed_implants": [],
		"training": {"active": false, "kind": "", "end_time": 0.0, "quality": 0.0},
		"activity": {"active": false, "kind": "", "end_time": 0.0},
		"week": {"index": 1, "last_competition": 0.0, "claimed_week": 0},
		"competition": {"last_rank": -1, "last_score": 0.0},
		"core_fragments": 0,
		"prestige_count": 0,
		"meta_upgrades": MODELS.default_meta_upgrades(),
		"settings": {"crt_enabled": true}
	}

func create_new_profile(player_name: String, starter_id: String) -> void:
	save = default_save()
	save.initialized = true
	save.profile.name = player_name
	for p in PETS.starters():
		if p.id == starter_id:
			save.pet = {
				"id": p.id,
				"name": p.name,
				"color": p.color.to_html(false),
				"base_stats": p.base_stats.duplicate(true),
				"growth": p.growth.duplicate(true),
				"bonus_stats": {"hp": 0, "attack": 0, "defense": 0, "speed": 0, "tech": 0, "energy": 0, "luck": 0},
				"level": 1,
				"xp": 0,
				"hp_current": p.base_stats.hp,
				"mood": 80,
				"maintenance": 25,
				"energy_current": p.base_stats.energy
			}
			break
	_grant_starter_items()
	save_game()
	emit_signal("data_changed")

func _grant_starter_items() -> void:
	var gear_ids: Array = GEAR.all().keys()
	var implant_ids: Array = IMPLANTS.all().keys()
	save.inventory.gear.append(gear_ids[0])
	save.inventory.gear.append(gear_ids[1])
	save.inventory.implants.append(implant_ids[0])

func load_game() -> void:
	save = PERSIST.load_data()
	if save.is_empty():
		save = default_save()
	tick_background()
	emit_signal("data_changed")

func save_game(_reason: String = "") -> void:
	PERSIST.save_data(save)

func request_scene(name: String) -> void:
	emit_signal("scene_requested", name)

func tick_background() -> void:
	if not save.get("initialized", false):
		return
	var now: float = Time.get_unix_time_from_system()
	if save.training.active and now >= float(save.training.end_time):
		collect_training()
	if save.activity.active and now >= float(save.activity.end_time):
		collect_activity()
	if now - float(save.week.last_competition) > 7.0 * 24.0 * 3600.0:
		save.week.index += 1

func get_meta_multiplier(key: String) -> float:
	var up: Variant = save.meta_upgrades.get(key, null)
	if up == null:
		return 0.0
	return up.level * up.per_level

func get_pet_stats() -> Dictionary:
	var stats: Dictionary = save.pet.base_stats.duplicate(true)
	for k in save.pet.bonus_stats.keys():
		stats[k] += int(save.pet.bonus_stats[k])
	stats.hp += int(get_meta_multiplier("base_hp"))
	stats.attack += int(get_meta_multiplier("base_attack"))
	for slot in save.equipped_gear.keys():
		var item_id: String = str(save.equipped_gear[slot])
		if item_id != "":
			var item: Dictionary = GEAR.all()[item_id]
			for s in item.stats.keys():
				stats[s] += item.stats[s]
	for implant_id in save.installed_implants:
		if IMPLANTS.all().has(implant_id):
			for s in IMPLANTS.all()[implant_id].passive.keys():
				stats[s] += IMPLANTS.all()[implant_id].passive[s]
	return stats

func add_xp(amount: int) -> void:
	save.pet.xp += amount
	while save.pet.xp >= MODELS.xp_to_next(save.pet.level):
		save.pet.xp -= MODELS.xp_to_next(save.pet.level)
		save.pet.level += 1
		for key in save.pet.base_stats.keys():
			save.pet.bonus_stats[key] += save.pet.growth[key]
	emit_signal("data_changed")

func start_training(kind: String) -> void:
	var base: float = float(TRAIN_SYS.durations().get(kind, 30))
	var mult: float = 1.0 - get_meta_multiplier("training_speed")
	save.training = {
		"active": true,
		"kind": kind,
		"end_time": Time.get_unix_time_from_system() + base * maxf(0.35, mult),
		"quality": 0.0
	}
	save_game()
	emit_signal("data_changed")

func apply_training_minigame(quality: float) -> void:
	if not save.training.active:
		return
	save.training.quality = maxf(save.training.quality, quality)
	save.training.end_time -= 3.0 + 6.0 * quality
	save_game()
	emit_signal("data_changed")

func collect_training() -> void:
	if not save.training.active:
		return
	var reward: Dictionary = TRAIN_SYS.reward_for(save.training.kind, float(save.training.quality), save.pet.level)
	for k in reward.keys():
		save.pet.bonus_stats[k] += reward[k]
	save.pet.mood = clampi(save.pet.mood + 4, 0, 100)
	save.training = {"active": false, "kind": "", "end_time": 0.0, "quality": 0.0}
	save_game()
	emit_signal("data_changed")

func start_activity(kind: String) -> void:
	var base: float = float(ACT_SYS.durations().get(kind, 40))
	save.activity = {"active": true, "kind": kind, "end_time": Time.get_unix_time_from_system() + base}
	save_game()
	emit_signal("data_changed")

func collect_activity() -> void:
	if not save.activity.active:
		return
	var bonus: float = 1.0 + get_meta_multiplier("activity_reward")
	var reward: Dictionary = ACT_SYS.reward_for(save.activity.kind, bonus)
	if save.activity.kind == "scavenge":
		save.inventory.credits += reward.credits
		save.inventory.materials += reward.materials
		if reward.gear_drop:
			var g: Array = GEAR.all().keys()
			save.inventory.gear.append(g[randi() % g.size()])
		if reward.implant_drop:
			var i: Array = IMPLANTS.all().keys()
			save.inventory.implants.append(i[randi() % i.size()])
	else:
		save.pet.energy_current = mini(get_pet_stats().energy, save.pet.energy_current + reward.energy)
		save.pet.mood = clampi(save.pet.mood + reward.mood, 0, 100)
		save.pet.hp_current = mini(get_pet_stats().hp, save.pet.hp_current + reward.hp)
	save.activity = {"active": false, "kind": "", "end_time": 0.0}
	save_game()
	emit_signal("data_changed")

func start_exploration() -> void:
	current_run = EXPLORE_SYS.create_run(save.pet.level)
	emit_signal("data_changed")

func open_combat(enemy: Dictionary) -> void:
	emit_signal("combat_requested", enemy)

func can_prestige() -> bool:
	return save.pet.level >= 20

func do_prestige() -> void:
	if not can_prestige():
		return
	var stats: Dictionary = get_pet_stats()
	var total: int = 0
	for v in stats.values():
		total += int(v)
	var fragments: int = int(floor(save.pet.level / 5.0) + floor(total / 60.0))
	save.core_fragments += maxi(1, fragments)
	save.prestige_count += 1
	save.pet.level = 1
	save.pet.xp = 0
	for k in save.pet.bonus_stats.keys():
		save.pet.bonus_stats[k] = 0
	current_run = {}
	save_game()
	emit_signal("data_changed")

func upgrade_cost(key: String) -> int:
	var up: Dictionary = save.meta_upgrades[key]
	return up.base_cost + up.level * up.cost_scale

func buy_meta_upgrade(key: String) -> bool:
	if not save.meta_upgrades.has(key):
		return false
	var up: Dictionary = save.meta_upgrades[key]
	if up.level >= up.max:
		return false
	var cost: int = upgrade_cost(key)
	if save.core_fragments < cost:
		return false
	save.core_fragments -= cost
	save.meta_upgrades[key].level += 1
	save_game()
	emit_signal("data_changed")
	return true
