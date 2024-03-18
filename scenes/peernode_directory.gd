extends Node
class_name PeerNodeDirectory


## The scene to instantiate on creation of a new [PeerNode].
@export var peernode_scene: PackedScene = preload("res://scenes/peernode.tscn")


## Find the subordinate [PeerNode] with the given peer_id, and return it if found, otherwise return null.
func get_peernode(peer_id: int) -> PeerNode:
	return get_node_or_null("%d" % peer_id)


## Create a new [PeerNode] for the given peer_id, or do nothing if it already exists.
@rpc("authority", "call_local", "reliable")
func rpc_create_peernode(peer_id: int):
	# Make sure the peernode does not exist
	var peernode: PeerNode = get_peernode(peer_id)
	if peernode != null:
		return
	# Create a new peernode
	peernode = peernode_scene.instantiate()
	peernode.set_multiplayer_authority(peer_id)
	peernode.identified.connect(_on_peernode_identified.bind(peernode))
	peernode.name = "%d" % peer_id
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


func _on_peernode_created(peernode: PeerNode) -> void:
	if peernode.is_multiplayer_authority():
		local_peernode_created.emit(peernode)

## Emitted on a client when the [PeerNode] for itself has been created.
signal local_peernode_created(peernode: PeerNode)


## Called on the server when a [PeerNode] calls [method rpc_identify] for itself.
func _on_peernode_identified(player_name: String, peernode: PeerNode):
	peernode_identified.emit(player_name, peernode)

## Emitted on the server when a [PeerNode] calls [method rpc_identify] for itself.
signal peernode_identified(player_name: String, peernode: PeerNode)
