extends Node
class_name PlayerNodeDirectory


## The scene to instantiate on creation of a new [PlayerNode].
@export var playernode_scene: PackedScene = preload("res://scenes/playernode.tscn")


## Cache dictionary mapping player names to their respective [PlayerNode].
##
## This script is responsible for keeping it updated.
var playernodes_by_name: Dictionary = {}


## Find the subordinate [PlayerNode] with the given player_name, and return it if found, otherwise return null.
func get_playernode(player_name: String) -> PlayerNode:
	return playernodes_by_name.get(player_name)


## Create a new [PlayerNode] for the given [param player_name], giving control of it to [param peer_id].
##
## If a node with the given name already exists, only its multiplayer authority is changed, leaving the rest intact.
##
## If both node and multiplayer authority match the requested values, nothing is done at all.
@rpc("authority", "call_local", "reliable")
func rpc_possess_playernode(player_name: String, peer_id: int):
	var playernode: PlayerNode = get_playernode(player_name)
	# If the playernode does not exist, create it
	if playernode == null:
		playernode = playernode_scene.instantiate()
		playernode.name_changed.connect(_on_playernode_name_changed.bind(playernode))
		playernode.color_changed.connect(_on_playernode_color_changed.bind(playernode))
		playernode.possessed.connect(_on_playernode_possessed.bind(playernode))
		add_child(playernode, true)
	# If the multiplayer authority does not match the requested one, make it match
	playernode.possess(peer_id)



func _on_playernode_name_changed(old: String, new: String, playernode: PlayerNode):
	playernodes_by_name.erase(old)
	playernodes_by_name[new] = playernode
	playernode_name_changed.emit(old, new, playernode)

func _on_playernode_color_changed(old: Color, new: Color, playernode: PlayerNode):
	playernode_color_changed.emit(old, new, playernode)

func _on_playernode_possessed(old: int, new: int, playernode: PlayerNode):
	playernode_possessed.emit(old, new, playernode)


## Emitted when the name of one of the children [PlayerNode]s changes on the local scene.
signal playernode_name_changed(old: String, new: String, playernode: PlayerNode)

## Emitted when the name of one of the children [PlayerNode]s changes on the local scene.
signal playernode_color_changed(old: Color, new: Color, playernode: PlayerNode)

## Emitted everywhere when one of the children [PlayerNode]s has changed multiplayer authority.
signal playernode_possessed(old: int, new: int, playernode: PlayerNode)
