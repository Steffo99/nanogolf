extends Node2D
class_name GolfTee


## The [GolfBall] [PackedScene] to [method spawn]. 
const ball_scene: PackedScene = preload("res://scenes/golf_ball.tscn")


## Create a new [GolfBall] from [field ball_scene], initialize it with details from the given [PlayerNode], and return it.
##
## Note that this does not add the [GolfBall] to the scene tree, as it is the [GolfLevel]'s responsibility to do so.
func create(playernode: PlayerNode) -> GolfBall:
	# Create the [GolfBall]
	var obj: GolfBall = ball_scene.instantiate()
	# Setup the initial values
	obj.global_position = global_position
	obj.player_name = playernode.player_name
	obj.player_color = playernode.player_color
	obj.set_multiplayer_authority(playernode.get_multiplayer_authority())
	# Create callables to be able to cleanup signals on destruction
	var on_name_changed: Callable = _on_name_changed.bind(obj)
	var on_color_changed: Callable = _on_color_changed.bind(obj)
	var on_possessed: Callable = _on_possessed.bind(obj)
	var on_cleanup: Callable = _on_cleanup.bind(playernode, on_name_changed, on_color_changed, on_possessed)
	# Setup signals to keep properties updated
	playernode.name_changed.connect(on_name_changed)
	playernode.color_changed.connect(on_color_changed)
	playernode.possessed.connect(on_possessed)
	obj.tree_exiting.connect(on_cleanup)
	# Return the created [GolfBall]
	return obj


func _on_name_changed(_old: String, new: String, obj: GolfBall) -> void:
	obj.player_name = new

func _on_color_changed(_old: Color, new: Color, obj: GolfBall) -> void:
	obj.player_color = new

func _on_possessed(_old: int, new: int, obj: GolfBall) -> void:
	obj.set_multiplayer_authority(new)

func _on_cleanup(playernode: PlayerNode, on_name_changed: Callable, on_color_changed: Callable, on_possessed: Callable) -> void:
	playernode.name_changed.disconnect(on_name_changed)
	playernode.color_changed.disconnect(on_color_changed)
	playernode.possessed.disconnect(on_possessed)
