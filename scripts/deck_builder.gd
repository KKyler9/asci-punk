extends Control

signal request_back
signal request_run

const CardsContentRes = preload("res://scripts/content/cards.gd")
const DeckSystemRes = preload("res://scripts/systems/deck_system.gd")
const SynergySystemRes = preload("res://scripts/systems/synergy_system.gd")

@onready var collection_list: ItemList = $Root/CollectionCol/CollectionList
@onready var deck_list: ItemList = $Root/DeckCol/DeckList
@onready var info_label: Label = $Root/DeckCol/InfoLabel
@onready var synergy_label: Label = $Root/DeckCol/SynergyLabel

var card_map := {}

func _ready() -> void:
	card_map = CardsContentRes.by_id_map()
	_refresh()

func _refresh() -> void:
	var p: Dictionary = GameState.save.player
	collection_list.clear()
	for id in p.collection.keys():
		collection_list.add_item("%s x%d" % [card_map[id].name, p.collection[id]])
		collection_list.set_item_metadata(collection_list.item_count - 1, id)
	deck_list.clear()
	for i in p.deck.size():
		var id = p.deck[i]
		deck_list.add_item("%02d. %s" % [i + 1, card_map[id].name])
		deck_list.set_item_metadata(i, i)
	var syn := SynergySystemRes.analyze(p.deck)
	synergy_label.text = "Synergy:\n" + "\n".join(syn.notes)
	if syn.notes.is_empty():
		synergy_label.text += "\n(no active thresholds)"
	info_label.text = "Deck %d/%d" % [p.deck.size(), p.cyber_capacity]

func _on_add_pressed() -> void:
	if collection_list.get_selected_items().is_empty():
		return
	var idx := collection_list.get_selected_items()[0]
	var card_id: String = collection_list.get_item_metadata(idx)
	if DeckSystemRes.add_to_deck(GameState.save.player, card_id):
		GameState.save_game("Deck updated")
	_refresh()

func _on_remove_pressed() -> void:
	if deck_list.get_selected_items().is_empty():
		return
	var idx := deck_list.get_selected_items()[0]
	DeckSystemRes.remove_from_deck(GameState.save.player, idx)
	GameState.save_game("Deck updated")
	_refresh()

func _on_back_pressed() -> void:
	emit_signal("request_back")

func _on_start_run_pressed() -> void:
	emit_signal("request_run")
