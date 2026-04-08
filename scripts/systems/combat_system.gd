extends RefCounted
class_name CombatSystem

const CARDS = preload("res://scripts/content/cards.gd")

static func damage(atk: int, defense: int, variance: int = 2) -> int:
	var raw: int = atk - int(defense * 0.45) + randi_range(-variance, variance)
	return maxi(1, raw)

static func ability_name(implants: Array) -> String:
	if implants.is_empty():
		return "No Implant"
	return str(implants[0])

# Legacy deck-combat API used by combat_screen.gd
static func start_battle(player: Dictionary, enemy: Dictionary, _synergy: Dictionary, _rng: RandomNumberGenerator) -> Dictionary:
	var deck: Array = player.deck.duplicate(true)
	deck.shuffle()
	return {
		"enemy": enemy,
		"enemy_hp": int(enemy.hp),
		"draw": deck,
		"hand": [],
		"discard": [],
		"block": 0,
		"mana": 3,
		"log": ["Encounter: %s" % [str(enemy.name)]]
	}

static func refresh_turn(battle: Dictionary, _player: Dictionary) -> void:
	battle.mana = 3
	battle.block = 0
	_draw_cards(battle, 5)

static func play_card(battle: Dictionary, player: Dictionary, card_id: String) -> String:
	var card_map: Dictionary = CARDS.by_id_map()
	if not card_map.has(card_id):
		return "Unknown card"
	var card: Dictionary = card_map[card_id]
	var cost: int = int(card.get("cost", 1))
	if int(battle.mana) < cost:
		return "Not enough mana"
	battle.mana = int(battle.mana) - cost
	for effect_variant: Variant in card.get("effects", []):
		var effect: Dictionary = effect_variant
		var kind: String = str(effect.get("kind", ""))
		var value: int = int(effect.get("value", 0))
		match kind:
			"damage":
				var scale_key: String = str(effect.get("scale", "attack"))
				var attack_stat: int = int(player.stats.get(scale_key, player.stats.attack))
				var dealt: int = damage(value + attack_stat / 2, int(battle.enemy.defense), 1)
				battle.enemy_hp = int(battle.enemy_hp) - dealt
				battle.log.append("%s deals %d" % [str(card.name), dealt])
			"block":
				battle.block = int(battle.block) + value
				battle.log.append("Gained %d block" % [value])
			"heal":
				player.current_hp = mini(int(player.stats.max_hp), int(player.current_hp) + value)
				battle.log.append("Recovered %d HP" % [value])
			"draw":
				_draw_cards(battle, value)
				battle.log.append("Drew %d card(s)" % [value])
	battle.discard.append(card_id)
	return "ok"

static func cleanup_hand_to_discard(battle: Dictionary) -> void:
	for card_variant: Variant in battle.hand:
		battle.discard.append(card_variant)
	battle.hand.clear()

static func enemy_turn(battle: Dictionary, player: Dictionary) -> void:
	var incoming: int = damage(int(battle.enemy.attack), int(player.stats.defense), 1)
	var block: int = int(battle.block)
	var blocked: int = mini(block, incoming)
	incoming -= blocked
	battle.block = maxi(0, block - blocked)
	player.current_hp = maxi(0, int(player.current_hp) - incoming)
	battle.log.append("%s attacks for %d" % [str(battle.enemy.name), incoming])

static func _draw_cards(battle: Dictionary, amount: int) -> void:
	for _i in amount:
		if battle.draw.is_empty():
			if battle.discard.is_empty():
				return
			battle.draw = battle.discard.duplicate(true)
			battle.discard.clear()
			battle.draw.shuffle()
		battle.hand.append(battle.draw.pop_back())
