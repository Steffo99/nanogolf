extends Node
class_name Game



@export_category("References")

## The [PeerNodeDirectory] instance child of this node.
@export var peer_dir: PeerNodeDirectory = null

## The [PlayerNodeDirectory] instance child of this node.
@export var player_dir: PlayerNodeDirectory = null

## The [PhaseTracker] instance child of this node.
@export var phase_tracker: PhaseTracker = null

## The [LevelManager] instance child of this node.
@export var level_manager: LevelManager = null



## Emitted when the player has requested to exit from the game.
signal lost_connection 

## Emitted when the golf ball for the local player has been spawned.
##
## Used for [GameHUD] events.
signal local_player_spawned(ball: GolfBall)


## The name to be given to the player controlled by the local peer.
var local_player_name: String

## The color to be given to the player controlled by the local peer.
var local_player_color: Color


## Initialize some signals needed by this node to function properly.
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
	lost_connection.emit()

func _on_multiplayer_peer_connected(peer_id: int) -> void:
	Log.peer(self, "Peer connected: %d" % peer_id)
	if is_multiplayer_authority():
		for peernode in peer_dir.get_children():
			peer_dir.rpc_create_peernode.rpc_id(peer_id, peernode.get_multiplayer_authority())
		for playernode in player_dir.get_children():
			player_dir.rpc_possess_playernode.rpc_id(peer_id, playernode.player_name, playernode.get_multiplayer_authority())
			playernode.rpc_query_name.rpc_id(playernode.get_multiplayer_authority())
			playernode.rpc_query_color.rpc_id(playernode.get_multiplayer_authority())
			playernode.rpc_query_scores.rpc_id(playernode.get_multiplayer_authority())
		peer_dir.rpc_create_peernode.rpc(peer_id)

func _on_multiplayer_peer_disconnected(peer_id: int) -> void:
	Log.peer(self, "Peer disconnected: %d" % peer_id)
	if is_multiplayer_authority():
		for playernode in player_dir.get_children():
			if playernode.get_multiplayer_authority() == peer_id:
				player_dir.rpc_possess_playernode.rpc(playernode.player_name, 1)
		peer_dir.rpc_destroy_peernode.rpc(peer_id)


func _on_peerdir_local_peernode_created(peernode: PeerNode) -> void:
	Log.peer(self, "Local peernode created: %s" % peernode)
	peernode.rpc_identify.rpc(local_player_name)

func _on_peerdir_peernode_identified(player_name: String, peernode: PeerNode) -> void:
	Log.peer(self, "Peernode identified: %s → %s" % [peernode, player_name])
	if is_multiplayer_authority():
		var peer_id = peernode.get_multiplayer_authority()
		phase_tracker.rpc_set_phase.rpc_id(peer_id, phase_tracker.phase)
		level_manager.sync_level(peer_id)
		player_dir.rpc_possess_playernode.rpc(player_name, peer_id)


func _on_playerdir_playernode_created(playernode: PlayerNode) -> void:
	Log.peer(self, "Playernode created: %s" % playernode)
	if is_multiplayer_authority():
		level_manager.add_player(playernode)

func _on_playerdir_local_playernode_possessed(old: int, new: int, playernode: PlayerNode) -> void:
	Log.peer(self, "Local playernode possessed: %d → %d" % [old, new])
	playernode.rpc_set_name.rpc(local_player_name)
	playernode.rpc_set_color.rpc(local_player_color)

func _on_main_start_confirmed() -> void:
	if is_multiplayer_authority():
		phase_tracker.rpc_set_phase.rpc(PhaseTracker.Phase.PLAYING)
		level_manager.next_level()

func _on_level_manager_playlist_complete(_playlist: LevelPlaylist) -> void:
	if is_multiplayer_authority():
		phase_tracker.rpc_set_phase.rpc(PhaseTracker.Phase.ENDED)
