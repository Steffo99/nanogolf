extends PanelContainer
class_name PlayerNameInput


signal name_confirmed(selected_name: String)

var selected_name: String = "":
	get:
		return selected_name
	set(value):
		selected_name = value

@onready var line_edit: LineEdit = $"Layout/LineEdit"


func _on_line_edit_text_changed(new_text: String):
	selected_name = new_text


func _on_button_pressed():
	name_confirmed.emit(selected_name)


func _on_line_edit_text_submitted(new_text: String):
	selected_name = new_text
	name_confirmed.emit(selected_name)
