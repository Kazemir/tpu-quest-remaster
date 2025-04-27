extends Control

@onready var score_list: GridContainer = $MarginContainer/GridContainer/MarginContainer/ScoreList

func _on_ready() -> void:
	for child in score_list.get_children():
		score_list.remove_child(child)

	var scores = HighscoreManager.highscores
	for score in scores:
		var label_name = Label.new()
		label_name.text = score.name
		label_name.theme_type_variation = "ScoreUsername"
		score_list.add_child(label_name)

		var label_score = Label.new()
		label_score.text = "%09d" % score.score
		label_score.theme_type_variation = "ScoreValue"
		score_list.add_child(label_score)

	for i in range(scores.size(), 11):
		var label_name = Label.new()
		label_name.text = "AAA"
		label_name.theme_type_variation = "ScoreUsername"
		score_list.add_child(label_name)

		var label_score = Label.new()
		label_score.text = "000000000"
		label_score.theme_type_variation = "ScoreValue"
		score_list.add_child(label_score)
