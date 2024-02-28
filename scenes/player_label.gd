extends Label
class_name PlayerLabel


func update_from_tracker(tracker: SinglePlayerTracker):
	text = tracker.player_name
	add_theme_color_override("font_color", tracker.player_color)
	modulate.a = 1.0 if tracker.peer_connected else 0.3
