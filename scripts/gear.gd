extends Control

@onready var gear_list: ItemList = $MarginContainer/HBoxContainer/GearList
@onready var implant_list: ItemList = $MarginContainer/HBoxContainer/ImplantList
@onready var equipped: Label = $MarginContainer/VBoxContainer/Equipped

func _ready() -> void:
	refresh()

func refresh() -> void:
	gear_list.clear()
	implant_list.clear()
	for g in GameState.save.inventory.gear:
		var data = preload("res://scripts/content/gear_data.gd").all()[g]
		gear_list.add_item("%s (%s)" % [data.name, g])
	for i in GameState.save.inventory.implants:
		var data_i = preload("res://scripts/content/implant_data.gd").all()[i]
		implant_list.add_item("%s (%s)" % [data_i.name, i])
	equipped.text = "Equipped Gear: %s\nImplants: %s" % [str(GameState.save.equipped_gear), str(GameState.save.installed_implants)]

func _on_equip_gear_pressed() -> void:
	var idx := gear_list.get_selected_items()
	if idx.is_empty():
		return
	var item_id = GameState.save.inventory.gear[idx[0]]
	var item = preload("res://scripts/content/gear_data.gd").all()[item_id]
	GameState.save.equipped_gear[item.slot] = item_id
	GameState.save_game()
	refresh()

func _on_install_implant_pressed() -> void:
	var idx := implant_list.get_selected_items()
	if idx.is_empty():
		return
	var item_id = GameState.save.inventory.implants[idx[0]]
	if not GameState.save.installed_implants.has(item_id):
		GameState.save.installed_implants.append(item_id)
	GameState.save_game()
	refresh()

func _on_back_pressed() -> void:
	GameState.request_scene("home")
