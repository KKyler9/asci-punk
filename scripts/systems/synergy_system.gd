extends RefCounted
class_name SynergySystem

const CardsContentRes = preload("res://scripts/content/cards.gd")

static func analyze(deck: Array) -> Dictionary:
	var map := CardsContentRes.by_id_map()
	var totals := {"DMG-RED":0,"DEF-BLUE":0,"HACK-PURPLE":0,"UTIL-GREEN":0}
	for id in deck:
		if map.has(id):
			totals[map[id].cyber_type] += 1
	var count: int = max(deck.size(), 1)
	var red_ratio: float = float(totals["DMG-RED"]) / count
	var blue_ratio: float = float(totals["DEF-BLUE"]) / count
	var mods := {
		"damage_mult":1.0,
		"block_mult":1.0,
		"mana_bonus":0,
		"notes":[]
	}
	if red_ratio >= 0.4:
		mods.damage_mult += 0.15
		mods.block_mult -= 0.1
		mods.notes.append("Redline: +15% damage, -10% block")
	if blue_ratio >= 0.35:
		mods.block_mult += 0.2
		mods.mana_bonus -= 1
		mods.notes.append("Blue Bastion: +20% block, -1 mana")
	return mods
