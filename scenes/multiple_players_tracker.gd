extends MultiplayerSpawner
class_name MultiplePlayersTracker

# Requires the peer_id as data for the spawn function.


func get_tracker_by_peer(peer_id: int) -> SinglePlayerTracker:
	for child in find_children("", "SinglePlayerTracker", false):
		if child.peer_id == peer_id:
			return child
	return null

func init_tracker(peer_id: int) -> SinglePlayerTracker:
	var existing_tracker: SinglePlayerTracker = get_tracker_by_peer(peer_id)
	if existing_tracker != null:
		return existing_tracker
	var single_tracker_instance = spawn(peer_id) 
	return single_tracker_instance


func _ready():
	spawn_function = _spawn_tracker

func _spawn_tracker(data: Variant) -> Node:
	print("Spawning ", data)
	var single_tracker_scene: PackedScene = load(get_spawnable_scene(0))
	var single_tracker_instance: SinglePlayerTracker = single_tracker_scene.instantiate()
	single_tracker_instance.peer_id = data
	return single_tracker_instance


func _process(delta):
	if multiplayer.is_server() and Input.is_action_just_pressed("ui_accept"):
		spawn(1)
