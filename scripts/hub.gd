extends Control

signal request_run
signal request_deck_builder
signal request_crt_toggle(enabled: bool)

@onready var summary: Label = $MainPanel/Summary
@onready var account_panel: PanelContainer = $AccountPanel
@onready var main_panel: VBoxContainer = $MainPanel
@onready var handle_edit: LineEdit = $AccountPanel/VBox/HandleEdit
@onready var rig_option: OptionButton = $AccountPanel/VBox/RigOption
@onready var class_choice: HBoxContainer = $MainPanel/ClassChoice
@onready var perk_choice: HBoxContainer = $MainPanel/PerkChoice
@onready var crt_toggle: CheckButton = $MainPanel/CrtToggle

func _ready() -> void:
	rig_option.add_item("Assault")
	rig_option.add_item("Cipher")
	rig_option.add_item("Ghost")
	crt_toggle.button_pressed = bool(GameState.save.settings.crt_enabled)
	_refresh()

func _refresh() -> void:
	var p := GameState.save.player
	var has_account := p.handle != ""
	account_panel.visible = not has_account
	main_panel.visible = has_account
	if has_account:
		summary.text = "%s [%s]\nLv %d (%d/%d XP)\nHP %d/%d  ATK %d  MAG %d  INT %d\nDeck %d/%d\nPerks: %s" % [
			p.handle, p.rig, p.level, p.xp, p.next_xp, p.current_hp, p.stats.max_hp,
			p.stats.attack, p.stats.magic, p.stats.intelligence,
			p.deck.size(), p.cyber_capacity, ", ".join(p.perks)
		]
	class_choice.visible = bool(p.pending_class_choice)
	perk_choice.visible = int(p.pending_perk_choices) > 0

func _on_create_account_pressed() -> void:
	GameState.ensure_account(handle_edit.text, rig_option.get_item_text(rig_option.selected))
	_refresh()

func _on_start_run_pressed() -> void:
	emit_signal("request_run")

func _on_deck_builder_pressed() -> void:
	emit_signal("request_deck_builder")

func _on_save_pressed() -> void:
	GameState.save_game("Manual save")

func _on_stat_hp_pressed() -> void:
	GameState.apply_stat_choice("max_hp")
	_refresh()

func _on_stat_atk_pressed() -> void:
	GameState.apply_stat_choice("attack")
	_refresh()

func _on_stat_mag_pressed() -> void:
	GameState.apply_stat_choice("magic")
	_refresh()

func _on_stat_int_pressed() -> void:
	GameState.apply_stat_choice("intelligence")
	_refresh()

func _on_class_pick_pressed(class_name: String) -> void:
	GameState.choose_class(class_name)
	_refresh()

func _on_perk_pick_pressed(perk_name: String) -> void:
	GameState.choose_perk(perk_name)
	_refresh()

func _on_crt_toggle_toggled(toggled_on: bool) -> void:
	emit_signal("request_crt_toggle", toggled_on)

func _input(event: InputEvent) -> void:
	if not main_panel.visible:
		return
	if event.is_action_pressed("hotkey_start_run"):
		_on_start_run_pressed()
	elif event.is_action_pressed("hotkey_deck_builder"):
		_on_deck_builder_pressed()
