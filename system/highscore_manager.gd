extends Node

const FILE_PATH = "user://highscores.json"

var json = JSON.new()

var highscores: Array = []

func _ready() -> void:
	_load_highscores()

func _load_highscores() -> void:
	var file = FileAccess.open(FILE_PATH, FileAccess.ModeFlags.READ)
	if file != null:
		var json_string = file.get_as_text()
		file.close()
		if json_string != "":
			var error = json.parse(json_string)
			if error == OK:
				var data_received = json.data
				if typeof(data_received) == TYPE_ARRAY:
					highscores = (data_received as Array)
					highscores.sort_custom(func(a: Dictionary, b: Dictionary): return a.score > b.score)
				else:
					print("Unexpected data: ", data_received)
					highscores = []
			else:
				print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
				highscores = []
	else:
		highscores = []

func add_highscore(name: String, score: int):
	highscores.append({
		"name": name.substr(0, 12),
		"score": min(score, 999999999)
	})
	highscores.sort_custom(func(a: Dictionary, b: Dictionary): return a.score > b.score)
	highscores = highscores.slice(0, 10)
	_save_highscores()

func _save_highscores():
	var file = FileAccess.open(FILE_PATH, FileAccess.ModeFlags.WRITE)
	if file != null:
		var data = JSON.stringify(highscores)
		file.store_string(data)
		file.close()
