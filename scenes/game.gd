extends Node
class_name Game

## The name to be given to the player controlled by the local peer.
var local_player_name: String

## The color to be given to the player controlled by the local peer.
var local_player_color: Color

## The [PeerNodeDirectory] instance child of this node.
@onready var peer_dir: PeerNodeDirectory = $"PeerNodeDirectory"

## The [PlayerNodeDirectory] instance child of this node.
@onready var player_dir: PlayerNodeDirectory = $"PlayerNodeDirectory"


func init_signals() -> void:
	multiplayer.connected_to_server.connect(_on_multiplayer_connected_to_server)
	multiplayer.server_disconnected.connect(_on_multiplayer_disconnected_from_server)
	multiplayer.connection_failed.connect(_on_multiplayer_connection_failed)
	multiplayer.peer_connected.connect(_on_multiplayer_peer_connected)
	multiplayer.peer_disconnected.connect(_on_multiplayer_peer_disconnected)


func _on_multiplayer_connected_to_server() -> void:
	Log.peer(self, "Connected to server!")

func _on_multiplayer_disconnected_from_server() -> void:
	Log.peer(self, "Disconnected from server.")

func _on_multiplayer_connection_failed() -> void:
	Log.peer(self, "Connection failed...")

func _on_multiplayer_peer_connected(peer_id: int) -> void:
	Log.peer(self, "Peer connected: %d" % peer_id)
	if multiplayer.is_server():
		for peernode in peer_dir.get_children():
			peer_dir.rpc_create_peernode.rpc_id(peer_id, peernode.get_multiplayer_authority())
		peer_dir.rpc_create_peernode.rpc(peer_id)

func _on_multiplayer_peer_disconnected(peer_id: int) -> void:
	Log.peer(self, "Peer disconnected: %d" % peer_id)
	if multiplayer.is_server():
		peer_dir.rpc_destroy_peernode(peer_id)


func _on_peerdir_peernode_created(peernode: PeerNode) -> void:
	Log.peer(self, "Peernode created: %d" % peernode.get_multiplayer_authority())
	if peernode.is_multiplayer_authority():
		peernode.rpc_identify.rpc(local_player_name)

func _on_peerdir_peernode_destroyed(peernode: PeerNode) -> void:
	Log.peer(self, "Peernode destroyed: %d" % peernode.get_multiplayer_authority())
	for playernode in player_dir.get_children():
		if playernode.get_multiplayer_authority() == peernode.get_multiplayer_authority():
			playernode.possess(1)

func _on_peerdir_peernode_identified(player_name: String, peernode: PeerNode) -> void:
	Log.peer(self, "Peernode identified: %d → %s" % [peernode.get_multiplayer_authority(), player_name])
	player_dir.rpc_possess_playernode.rpc(player_name, peernode.get_multiplayer_authority())


func _on_playerdir_playernode_created(playernode: PlayerNode) -> void:
	Log.peer(self, "Playernode `%s` created" % playernode.name)

func _on_playerdir_playernode_destroyed(playernode: PlayerNode) -> void:
	Log.peer(self, "Playernode `%s` destroyed" % playernode.name)
	# Technically, this shouldn't ever happen

func _on_playerdir_playernode_name_changed(old: String, new: String, playernode: PlayerNode) -> void:
	Log.peer(self, "Playernode `%s` changed name: %s (was %s)" % [playernode.name, new, old])

func _on_playerdir_playernode_color_changed(old: Color, new: String, playernode: PlayerNode) -> void:
	Log.peer(self, "Playernode `%s` changed color: %s (was %s)" % [playernode.name, new, old])

func _on_playerdir_playernode_possessed(old: int, new: int, playernode: PlayerNode) -> void:
	Log.peer(self, "Playernode `%s` possessed: %d (was %d)" % [playernode.name, new, old])
	if playernode.is_multiplayer_authority():
		playernode.rpc_set_name.rpc(local_player_name)
		playernode.rpc_set_color.rpc(local_player_color)
