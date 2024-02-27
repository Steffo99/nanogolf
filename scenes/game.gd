extends Node
class_name Game


# This cannot be called in _ready because the multiplayer node is set *after* adding the node to the tree.
func init_signals():
	print("[Game] Initializing signals...")
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _on_connected_to_server():
	print("{", multiplayer.multiplayer_peer.get_unique_id(), "} Connected to server!")

func _on_server_disconnected():
	print("{", multiplayer.multiplayer_peer.get_unique_id(), "} Server disconnected...")

func _on_connection_failed():
	print("{", multiplayer.multiplayer_peer.get_unique_id(), "} Connection failed...")

func _on_peer_connected(peer_id: int):
	print("{", multiplayer.multiplayer_peer.get_unique_id(), "} Peer connected: ", peer_id)

func _on_peer_disconnected(peer_id: int):
	print("{", multiplayer.multiplayer_peer.get_unique_id(), "} Peer disconnected: ", peer_id)
