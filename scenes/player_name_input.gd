extends PanelContainer
class_name PlayerNameInput


signal name_confirmed(selected_name: String)

@onready var line_edit: LineEdit = $"Layout/LineEdit"


func _on_button_pressed():
	name_confirmed.emit(line_edit.text)

func _on_line_edit_text_submitted(_new_text: String):
	name_confirmed.emit(line_edit.text)
