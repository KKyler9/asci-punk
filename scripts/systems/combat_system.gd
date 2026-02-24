extends RefCounted
class_name CombatSystem

const CardsContentRes = preload("res://scripts/content/cards.gd")

static func start_battle(player: Dictionary, enemy: Dictionary, synergy: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var draw: Array = player.deck.duplicate()
	draw.shuffle()
	if player.get("rig","") == "Ghost":
		draw.shuffle()
	return {
		"enemy": enemy.duplicate(true),
		"enemy_hp": enemy.max_hp,
		"enemy_block": 0,
		"enemy_weak": 0,
		"draw_pile": draw,
		"discard": [],
		"hand": [],
		"block": 0,
		"turn": 1,
		"mana": 0,
		"intent": "Attack",
		"synergy": synergy,
		"log": ["Encounter: %s" % enemy.name],
		"rng_seed": rng.randi()
	}

static func refresh_turn(battle: Dictionary, player: Dictionary) -> void:
	battle.block = 0
	battle.mana = max(1, int(player.stats.intelligence / 2) + 2 + int(battle.synergy.mana_bonus))
	draw_cards(battle, 5)
	battle.intent = "Attack %d" % (battle.enemy.attack + randi() % 3)

static func draw_cards(battle: Dictionary, amount: int) -> void:
	for _i in amount:
		if battle.draw_pile.is_empty():
			battle.draw_pile = battle.discard.duplicate()
			battle.discard.clear()
			battle.draw_pile.shuffle()
		if battle.draw_pile.is_empty():
			break
		battle.hand.append(battle.draw_pile.pop_back())

static func play_card(battle: Dictionary, player: Dictionary, card_id: String) -> String:
	var map := CardsContentRes.by_id_map()
	if not map.has(card_id):
		return "Unknown card"
	var card: Dictionary = map[card_id]
	if battle.mana < int(card.cost):
		return "Not enough mana"
	battle.mana -= int(card.cost)
	for effect in card.effects:
		_apply_effect(effect, battle, player)
	battle.discard.append(card_id)
	battle.log.append("Played %s" % card.name)
	return "ok"

static func _apply_effect(effect: Dictionary, battle: Dictionary, player: Dictionary) -> void:
	match effect.kind:
		"damage":
			var scale_stat := String(effect.get("scale", "attack"))
			var stat_val := int(player.stats.get(scale_stat, 0))
			var base := int(effect.value)
			var dmg := int((base + stat_val) * float(battle.synergy.damage_mult))
			if battle.enemy_weak > 0:
				dmg += 2
			var blocked: int = min(dmg, int(battle.enemy_block))
			battle.enemy_block -= blocked
			battle.enemy_hp -= max(0, dmg - blocked)
		"block":
			battle.block += int(round(int(effect.value) * float(battle.synergy.block_mult)))
		"heal":
			player.current_hp = min(player.stats.max_hp, player.current_hp + int(effect.value))
		"draw":
			draw_cards(battle, int(effect.value))
		"enemy_weak":
			battle.enemy_weak += int(effect.value)

static func enemy_turn(battle: Dictionary, player: Dictionary) -> void:
	var dmg := int(battle.enemy.attack)
	if battle.enemy_weak > 0:
		dmg = max(1, dmg - 2)
		battle.enemy_weak -= 1
	if randi() % 5 == 0:
		battle.enemy_block += 4
		battle.log.append("Enemy fortified")
	var blocked: int = min(dmg, int(battle.block))
	battle.block -= blocked
	var taken: int = max(0, dmg - blocked)
	player.current_hp -= taken
	battle.log.append("Enemy hit for %d" % taken)
	battle.turn += 1
	battle.hand.clear()

static func cleanup_hand_to_discard(battle: Dictionary) -> void:
	for id in battle.hand:
		battle.discard.append(id)
	battle.hand.clear()
