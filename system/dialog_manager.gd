extends CanvasLayer

func is_dialog_shown() -> bool:
	return get_child_count() > 0

func show_dialog(dialog: Node):
	GameManager.is_in_dialog_menu = true
	GameManager.is_game_paused = true
	for child in get_children():
		remove_child(child)
	add_child(dialog)

func hide_dialog():
	for child in get_children():
		remove_child(child)
	GameManager.is_in_dialog_menu = false
	GameManager.is_game_paused = false
