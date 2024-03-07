extends Node
class_name MultiplePlayersTracker

## Manager of all the instances of [SinglePlayerTracker] for a given multiplayer room.
## 
## Authority of this object is always given to the server (1).
##
## The server uses its authority to assign authority to the child [SinglePlayerTracker]s.

## Emitted when a new [SinglePlayerTracker] is created.
signal created(tracker: SinglePlayerTracker)

## Emitted when any [SinglePlayerTracker] has changed.
signal changed(all_trackers: Array[SinglePlayerTracker])

## Emitted when any [SinglePlayerTracker] is about to be destroyed.
signal before_destroyed(tracker: SinglePlayerTracker)

## The scene to be instantiated.
const tracker_scene = preload("res://scenes/single_player_tracker.tscn")

## Return the [Array] of [SinglePlayerTrackers] managed by this object.
func find_all() -> Array[SinglePlayerTracker]:
	return find_children("", "SinglePlayerTracker", false, false) as Array[SinglePlayerTracker]

## Find the first [SinglePlayerTracker] over which the given peer id has authority.
func find_id(peer_id: int) -> SinglePlayerTracker:
	for tracker in find_all():
		if tracker.get_multiplayer_authority() == peer_id:
			return tracker
	return null

## Find the first [SinglePlayerTracker] over which the running instance has authority.
func find_self() -> SinglePlayerTracker:
	var self_id = multiplayer.multiplayer_peer.get_unique_id()
	return find_id(self_id)

## Find the first [SinglePlayerTracker] representing a player with the given name.
func find_name(player_name: String) -> SinglePlayerTracker:
	for tracker in find_all():
		if tracker.player_name == player_name:
			return tracker
	return null

## Create a new [SinglePlayerTracker] for the given peer id, or return the one that already exists.
@rpc("authority", "call_local", "reliable")
func create(peer_id: int) -> SinglePlayerTracker:
	var tracker = find_id(peer_id)
	if tracker != null:
		return tracker
	Log.peer(self, "Creating tracker for peer: %d" % peer_id)
	tracker = tracker_scene.instantiate()
	tracker.set_multiplayer_authority(peer_id)
	created.emit(tracker)
	var trackers = find_all()
	changed.emit(trackers)
	return tracker

## Destroy the [SinglePlayerTracker] for the given peer id, or do nothing if it already exists.
func destroy(peer_id: int) -> void:
	var tracker = find_id(peer_id)
	if tracker == null:
		return
	Log.peer(self, "Destroying tracker for peer: %d" % peer_id)
	before_destroyed.emit(tracker)
	tracker.queue_free()
	var trackers = find_all()
	changed.emit(trackers)
