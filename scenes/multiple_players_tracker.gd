extends MultiplayerSpawner
class_name MultiplePlayersTracker

# Requires the peer_id as data for the spawn function.

signal trackers_changed(trackers: Dictionary)

func emit_trackers_changed():
	trackers_changed.emit(trackers_by_peer_id)


var trackers_by_peer_id: Dictionary = {}


func find(peer_id: int) -> SinglePlayerTracker:
	return trackers_by_peer_id.get(peer_id)

@rpc("authority", "call_local", "reliable")
func mark_disconnected(peer_id: int):
	var single_tracker_instance = find(peer_id)
	single_tracker_instance.set_multiplayer_authority(1)
	single_tracker_instance.peer_connected = false
	emit_trackers_changed()

func _ready():
	spawn_function = _spawn_tracker

func _spawn_tracker(peer_id: int) -> Node:
	var single_tracker_scene: PackedScene = load(get_spawnable_scene(0))
	var single_tracker_instance: SinglePlayerTracker = single_tracker_scene.instantiate()
	single_tracker_instance.set_multiplayer_authority(peer_id)
	single_tracker_instance.identity_updated.connect(_on_tracker_identity_updated)
	trackers_by_peer_id[peer_id] = single_tracker_instance
	emit_trackers_changed()
	return single_tracker_instance

func _on_tracker_identity_updated(_player_name: String, _player_color: Color):
	emit_trackers_changed()
