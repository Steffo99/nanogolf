extends Control
class_name LobbyMenu


signal leave_confirmed
signal start_confirmed


var players_list: Container
var start_button: Button

func init_refs():
	players_list = $"Layout/PlayersList"
	start_button = $"Layout/HBoxContainer/StartButton"


func _on_leave_button_pressed() -> void:
	leave_confirmed.emit()

func _on_start_button_pressed() -> void:
	start_confirmed.emit()
