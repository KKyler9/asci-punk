extends RefCounted
class_name CardsContent

static func all_cards() -> Array[Dictionary]:
	return [
		{"id":"red_slash","name":"Red Slash","cyber_type":"DMG-RED","cost":1,"rarity":"common","description":"Deal 6 damage.","ascii_art_lines":[" /\\ ","<##>"," \\/ "],"effects":[{"kind":"damage","value":6,"scale":"attack"}]},
		{"id":"overclock_strike","name":"Overclock Strike","cyber_type":"DMG-RED","cost":2,"rarity":"common","description":"Deal 9 damage.","ascii_art_lines":["[==]"," || ","/__\\"],"effects":[{"kind":"damage","value":9,"scale":"attack"}]},
		{"id":"bleed_packet","name":"Bleed Packet","cyber_type":"DMG-RED","cost":1,"rarity":"uncommon","description":"Deal 4 damage twice.","ascii_art_lines":[" .--.","( xx)"," '--'"],"effects":[{"kind":"damage","value":4,"scale":"attack"},{"kind":"damage","value":4,"scale":"attack"}]},
		{"id":"finisher","name":"Finisher","cyber_type":"DMG-RED","cost":3,"rarity":"rare","description":"Deal 16 damage.","ascii_art_lines":[" \\||/ ","==[]=="," //||\\"],"effects":[{"kind":"damage","value":16,"scale":"attack"}]},
		{"id":"guard_matrix","name":"Guard Matrix","cyber_type":"DEF-BLUE","cost":1,"rarity":"common","description":"Gain 6 block.","ascii_art_lines":["+----+","| []|","+----+"],"effects":[{"kind":"block","value":6}]},
		{"id":"ice_wall","name":"ICE Wall","cyber_type":"DEF-BLUE","cost":2,"rarity":"common","description":"Gain 10 block.","ascii_art_lines":["||||||","|_[]_|","||||||"],"effects":[{"kind":"block","value":10}]},
		{"id":"reflect_shell","name":"Reflect Shell","cyber_type":"DEF-BLUE","cost":1,"rarity":"uncommon","description":"Gain 5 block, draw 1.","ascii_art_lines":[" /--\\","| ()|"," \\--/"],"effects":[{"kind":"block","value":5},{"kind":"draw","value":1}]},
		{"id":"ping_spike","name":"Ping Spike","cyber_type":"HACK-PURPLE","cost":1,"rarity":"common","description":"Deal 5 hack damage.","ascii_art_lines":[" .::.","(:::)"," '::'"],"effects":[{"kind":"damage","value":5,"scale":"magic"}]},
		{"id":"logic_bomb","name":"Logic Bomb","cyber_type":"HACK-PURPLE","cost":2,"rarity":"uncommon","description":"Deal 8 hack damage and weaken.","ascii_art_lines":[" .--. ","( !! )"," '--' "],"effects":[{"kind":"damage","value":8,"scale":"magic"},{"kind":"enemy_weak","value":1}]},
		{"id":"root_access","name":"Root Access","cyber_type":"HACK-PURPLE","cost":3,"rarity":"rare","description":"Deal 14 hack damage.","ascii_art_lines":["[root]","<====>","[____]"],"effects":[{"kind":"damage","value":14,"scale":"magic"}]},
		{"id":"reboot","name":"Reboot","cyber_type":"UTIL-GREEN","cost":1,"rarity":"common","description":"Heal 4 HP.","ascii_art_lines":[" .--. ","/ ++ \\"," '--' "],"effects":[{"kind":"heal","value":4}]},
		{"id":"packet_sniff","name":"Packet Sniff","cyber_type":"UTIL-GREEN","cost":1,"rarity":"common","description":"Draw 2 cards.","ascii_art_lines":["<..>"," || ","<..>"],"effects":[{"kind":"draw","value":2}]},
	]

static func starter_deck_for_rig(rig: String) -> Array[String]:
	var base: Array[String] = ["red_slash","red_slash","guard_matrix","guard_matrix","ping_spike","ping_spike","packet_sniff","reboot","overclock_strike","reflect_shell","bleed_packet","ice_wall"]
	if rig == "Assault":
		base.append("red_slash")
		base.erase("reboot")
	elif rig == "Cipher":
		base.append("ping_spike")
		base.erase("guard_matrix")
	elif rig == "Ghost":
		base.append("packet_sniff")
		base.erase("overclock_strike")
	return base

static func by_id_map() -> Dictionary:
	var out := {}
	for c in all_cards():
		out[c.id] = c
	return out
