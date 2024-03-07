extends Node
class_name Game


signal trackers_changed(trackers: Dictionary)

func _on_trackers_changed(trackers: Dictionary):
	trackers_changed.emit(trackers)


@onready var mp_tracker: MultiplePlayersTracker = $"MultiplePlayersTracker"


# This cannot be called in _ready because the multiplayer node is set *after* adding the node to the tree.
func init_signals():
	print("[Game] Initializing signals...")
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


var local_player_name: String = "Player"
var local_player_color: Color = Color.WHITE

func init_identity(player_name: String, player_color: Color):
	local_player_name = player_name
	local_player_color = player_color
	

func _on_connected_to_server():
	Log.peer(self, "Connected to server!")

func _on_server_disconnected():
	Log.peer(self, "Server disconnected...")

func _on_connection_failed():
	Log.peer(self, "Connection failed...")

func _on_peer_connected(peer_id: int):
	Log.peer(self, "Peer connected: " + str(peer_id))
	if multiplayer.is_server():
		assert(peer_id != 1, "This is a server, but the remote peer_id is 1.")
		Log.peer(self, "Initializing tracker for: " + str(peer_id))
		mp_tracker.create(peer_id)
	# Log.peer(self, "Setting multiplayer authority: " + str(peer_id))
	# var sp_tracker = mp_tracker.find(peer_id)
	# sp_tracker.set_multiplayer_authority(peer_id)

func _on_peer_disconnected(peer_id: int):
	Log.peer(self, "Peer disconnected: " + str(peer_id))
	if multiplayer.is_server():
		assert(peer_id != 1, "This is a server, but the remote peer_id is 1.")
		Log.peer(self, "Deinitializing tracker for: " + str(peer_id))
		mp_tracker.mark_disconnected.rpc(peer_id)
	# Log.peer(self, "Unsetting multiplayer authority: " + str(peer_id))
	# var sp_tracker = mp_tracker.find(peer_id)
	# sp_tracker.set_multiplayer_authority(1)

func _on_single_player_tracker_created(spawned_tracker: SinglePlayerTracker) -> void:
	# If we spawned ourselves, set our own identity
	if spawned_tracker.get_multiplayer_authority() == multiplayer.multiplayer_peer.get_unique_id():
		Log.peer(self, "Checking if we should notify our identity to everybody else...")
		spawned_tracker.update_identity.rpc(local_player_name, local_player_color)
	# If another player spawned, and they connected before us, send them our identity
	elif not multiplayer.is_server():
		Log.peer(self, "Checking if we should notify our identity to: " + str(spawned_tracker.get_multiplayer_authority()))
		var self_tracker = mp_tracker.find(multiplayer.multiplayer_peer.get_unique_id())
		if self_tracker != null:
			self_tracker.notify_identity(spawned_tracker.get_multiplayer_authority())
	# If we're the server, broadcast information about disconnected players
	else:
		Log.peer(self, "Checking if we should notify identity for disconnected peers...")
		for tracker in mp_tracker.find_children("", "SinglePlayerTracker", true, false):
			Log.peer(self, str(tracker))
			if tracker.get_multiplayer_authority() == 1:
				Log.peer(self, "I'm the authority, do notify.")
				tracker.notify_identity(spawned_tracker.get_multiplayer_authority())
			else:
				Log.peer(self, "I'm not the authority, do not notify.")
