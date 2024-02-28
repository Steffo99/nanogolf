extends PanelContainer
class_name PlayersList


@onready var layout = $"Scrollable/Layout"

const player_label_scene = preload("res://scenes/player_label.tscn")


func _on_trackers_changed(trackers: Dictionary):
	for child in layout.get_children():
		child.queue_free()
	for tracker in trackers.values():
		var player_label_instance = player_label_scene.instantiate()
		player_label_instance.update_from_tracker(tracker)
		layout.add_child(player_label_instance)
