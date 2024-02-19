extends PanelContainer
class_name ServerOptionsMenu


@export var port: int = 27015

signal hosting_confirmed(port: int)
signal connecting_confirmed(address: String, port: int)

var selected_address: String = "":
	get:
		return selected_address
	set(value):
		selected_address = value

@onready var line_edit: LineEdit = $"Layout/LineEdit"



func _on_line_edit_text_changed(new_text):
	selected_address = new_text

func _on_host_button_pressed():
	hosting_confirmed.emit(port)

func _on_connect_button_pressed():
	connecting_confirmed.emit(selected_address, port)
