extends RefCounted
class_name Models

static func default_player() -> Dictionary:
	return {
		"handle":"",
		"rig":"",
		"level":1,
		"xp":0,
		"next_xp":25,
		"class":"",
		"pending_class_choice":false,
		"pending_stat_points":0,
		"pending_perk_choices":0,
		"perks":[],
		"stats":{"max_hp":60,"attack":4,"magic":4,"intelligence":3},
		"current_hp":60,
		"cyber_capacity":12,
		"collection":{},
		"deck":[],
	}

static func default_run_state() -> Dictionary:
	return {
		"active":false,
		"grid":[],
		"width":20,
		"height":12,
		"player_pos":{"x":1,"y":1},
		"reward_cards":[],
		"summary":""
	}

static func default_settings() -> Dictionary:
	return {
		"deterministic_rng":true,
		"debug_seed":1337,
		"crt_enabled":true,
		"crt_params":{
			"scan_speed":0.22,
			"scan_strength":0.06,
			"noise_strength":0.03,
			"distortion_strength":0.02,
			"vignette_strength":0.18,
		}
	}
