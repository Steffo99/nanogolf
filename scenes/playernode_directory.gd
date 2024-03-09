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

## Called everywhere when a [PlayerNode] is renamed.
func _on_playernode_renamed(old_name: String, new_name: String) -> void:
	var playernode = playernodes_by_name.get(old_name)
	playernodes_by_name.erase(old_name)
	playernodes_by_name[new_name] = playernode


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
		add_child(playernode)
	# If the multiplayer authority does not match the requested one, make it match
	if playernode.get_multiplayer_authority() != peer_id:
		playernode.set_multiplayer_authority(peer_id)
		child_repossessed.emit(playernode)

## Emitted everywhere when one of the children [PlayerNode]s has changed multiplayer authority.
signal child_repossessed(playernode: PlayerNode)
