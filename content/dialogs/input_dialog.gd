class_name InputDialog
extends Control

@onready var caption_label: Label = $PanelContainer/VBoxContainer/PanelContainer/CenterContainer/CaptionLabel
@onready var message_label: Label = $PanelContainer/VBoxContainer/PanelContainer2/CenterContainer/MessageLabel
@onready var line_edit: LineEdit = $PanelContainer/VBoxContainer/PanelContainer3/CenterContainer/LineEdit

@export var dialog_data: InputDialogData = null

signal entered(text: String)

func _on_ready() -> void:
	if dialog_data == null:
		return

	caption_label.text = dialog_data.name
	message_label.text = dialog_data.message
	line_edit.grab_focus()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"action"):
		var text = line_edit.text
		if text.is_empty():
			entered.emit(null)
		else:
			entered.emit(text)
		DialogManager.hide_dialog()
	elif Input.is_action_just_pressed(&"escape"):
		entered.emit(null)
		DialogManager.hide_dialog()
