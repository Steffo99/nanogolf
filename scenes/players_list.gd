extends PanelContainer
class_name PlayersList


@onready var layout = $"Scrollable/Layout"

const label_scene: PackedScene = preload("res://scenes/player_label.tscn")

var labels_by_playernode: Dictionary = {}


func _on_playernode_created(playernode: PlayerNode) -> void:
	var label_instance = label_scene.instantiate()
	label_instance.set_player_name(playernode.player_name)
	label_instance.set_player_color(playernode.player_color)
	label_instance.set_possessed(playernode.get_multiplayer_authority())
	labels_by_playernode[playernode] = label_instance
	layout.add_child(label_instance)

func _on_playernode_destroyed(playernode: PlayerNode) -> void:
	labels_by_playernode[playernode].queue_free()
	labels_by_playernode.erase(playernode)

func _on_playernode_name_changed(_old: String, new: String, playernode: PlayerNode) -> void:
	labels_by_playernode[playernode].set_player_name(new)

func _on_playernode_color_changed(_old: Color, new: Color, playernode: PlayerNode) -> void:
	labels_by_playernode[playernode].set_player_color(new)

func _on_playernode_possessed(_old: int, new: int, playernode: PlayerNode) -> void:
	labels_by_playernode[playernode].set_possessed(new)

