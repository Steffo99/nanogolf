extends Node
class_name PeerNodeDirectory


## The scene to instantiate on creation of a new [PeerNode].
@export var peernode_scene: PackedScene = preload("res://scenes/peernode.tscn")


## Cache dictionary mapping peer_ids to their respective [PeerNode].
##
## This script is responsible for keeping it updated.
var peernodes_by_id: Dictionary = {}


## Find the subordinate [PeerNode] with the given peer_id, and return it if found, otherwise return null.
func get_peernode(peer_id: int) -> PeerNode:
	return peernodes_by_id.get(peer_id) as PeerNode


## Create a new [PeerNode] for the given peer_id, or do nothing if it already exists.
@rpc("authority", "call_local", "reliable")
func rpc_create_peernode(peer_id: int):
	# Make sure the peernode does not exist
	var peernode: PeerNode = get_peernode(peer_id)
	if peernode != null:
		return
	# Create a new peernode
	peernode = peernode_scene.instantiate()
	peernodes_by_id[peer_id] = peernode
	peernode.set_multiplayer_authority(peer_id)
	peernode.identified.connect(_on_peernode_identified.bind(peernode))
	add_child(peernode)


## Destroy the [PeerNode] for the given peer_id, or do nothing if it does not exist.
@rpc("authority", "call_local", "reliable")
func rpc_destroy_peernode(peer_id: int):
	# Make sure the peernode exists
	var peernode: PeerNode = get_peernode(peer_id)
	if peernode == null:
		return
	# Destroy the peernode
	peernode.queue_free()


## Called on the server when a [PeerNode] calls [method rpc_identify] for itself.
func _on_peernode_identified(peernode: PeerNode, player_name: String):
	peernode_identified.emit(peernode, player_name)

## Emitted on the server when a [PeerNode] calls [method rpc_identify] for itself.
signal peernode_identified(peernode: PeerNode, player_name: String)
