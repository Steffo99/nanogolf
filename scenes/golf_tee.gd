extends Node2D
class_name GolfTee


## Emitted when all connected [GolfBall]s have entered the hole.
signal everyone_entered_hole


## The [GolfBall] [PackedScene] to [method spawn]. 
const ball_scene: PackedScene = preload("res://scenes/golf_ball.tscn")


## Add a new [GolfBall] from [field ball_scene], initialize it with details from the given [PlayerNode], and return it.
func spawn(playernode: PlayerNode) -> GolfBall:
	# Create the [GolfBall]
	var obj: GolfBall = ball_scene.instantiate()
	# Setup the initial values
	obj.position = Vector2.ZERO
	obj.name = "GolfBall__%s" % playernode.player_name
	obj.player_name = playernode.player_name
	obj.player_color = playernode.player_color
	obj.set_multiplayer_authority(playernode.get_multiplayer_authority())
	obj.putt_controller.can_putt = not multiplayer.is_server() and playernode.is_multiplayer_authority()
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
	obj.entered_hole.connect(_on_entered_hole.bind(playernode))
	# Add the golf ball as a child of the tee
	add_child(obj)
	# Return the created [GolfBall]
	return obj


func is_everyone_in_hole() -> bool:
	for child in get_children():
		var ball: GolfBall = child as GolfBall
		if ball == null:
			# Ignore collision sounds
			continue
		if ball.get_multiplayer_authority() == 1:
			continue
		if not ball.in_hole:
			return false
	return true


func _on_name_changed(_old: String, new: String, obj: GolfBall) -> void:
	obj.name = "GolfBall__%s" % new
	obj.player_name = new

func _on_color_changed(_old: Color, new: Color, obj: GolfBall) -> void:
	obj.player_color = new

func _on_possessed(_old: int, new: int, obj: GolfBall) -> void:
	obj.set_multiplayer_authority(new)
	obj.putt_controller.can_putt = is_multiplayer_authority()

func _on_cleanup(playernode: PlayerNode, on_name_changed: Callable, on_color_changed: Callable, on_possessed: Callable) -> void:
	playernode.name_changed.disconnect(on_name_changed)
	playernode.color_changed.disconnect(on_color_changed)
	playernode.possessed.disconnect(on_possessed)

func _on_entered_hole(strokes: int, playernode: PlayerNode) -> void:
	if playernode.is_multiplayer_authority():
		playernode.report_score(strokes)
	if is_everyone_in_hole():
		everyone_entered_hole.emit()
