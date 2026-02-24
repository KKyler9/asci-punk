extends RefCounted
class_name DeckSystem

static func can_add_to_deck(player: Dictionary, card_id: String) -> bool:
	if player.deck.size() >= int(player.cyber_capacity):
		return false
	var owned := int(player.collection.get(card_id, 0))
	var in_deck := 0
	for id in player.deck:
		if id == card_id:
			in_deck += 1
	return in_deck < owned

static func add_to_deck(player: Dictionary, card_id: String) -> bool:
	if can_add_to_deck(player, card_id):
		player.deck.append(card_id)
		return true
	return false

static func remove_from_deck(player: Dictionary, idx: int) -> void:
	if idx >= 0 and idx < player.deck.size():
		player.deck.remove_at(idx)
