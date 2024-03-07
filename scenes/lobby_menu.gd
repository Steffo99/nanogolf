extends Control
class_name LobbyMenu


signal leave_confirmed
signal start_confirmed

@onready var players_list: PlayersList = $"Layout/PlayersList"


func _on_trackers_changed(trackers: Dictionary):
	players_list._on_trackers_changed(trackers)

func _on_leave_button_pressed() -> void:
	leave_confirmed.emit()

func _on_start_button_pressed() -> void:
	start_confirmed.emit()
