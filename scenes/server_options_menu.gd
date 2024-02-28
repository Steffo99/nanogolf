extends PanelContainer
class_name ServerOptionsMenu


@export var port: int = 12345

signal hosting_confirmed(port: int)
signal connecting_confirmed(address: String, port: int)

@onready var line_edit: LineEdit = $"Layout/LineEdit"


func _on_host_button_pressed():
	hosting_confirmed.emit(port)

func _on_connect_button_pressed():
	connecting_confirmed.emit(line_edit.text, port)
