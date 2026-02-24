extends RefCounted
class_name EnemiesContent

static func all_enemies() -> Array[Dictionary]:
	return [
		{
			"id":"sentinel",
			"name":"Sentinel",
			"max_hp":28,
			"attack":6,
			"frames":["  /\\\n [##]\n /__\\","  /\\\n [@@]\n /__\\"]
		},
		{
			"id":"crawler",
			"name":"Data Crawler",
			"max_hp":24,
			"attack":7,
			"frames":[" _.._\n( oo)\n/|__|\\"," _.._\n( ** )\n/|__|\\"]
		},
		{
			"id":"wraith",
			"name":"Wraith ICE",
			"max_hp":34,
			"attack":8,
			"frames":[" .--.\n(>< )\n '--'"," .--.\n( <> )\n '--'"]
		}
	]
