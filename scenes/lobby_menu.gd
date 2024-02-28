extends Control
class_name LobbyMenu


@onready var players_list: PlayersList = $"Layout/PlayersList"


func _on_trackers_changed(trackers: Dictionary):
	players_list._on_trackers_changed(trackers)
