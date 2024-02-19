extends CharacterBody2D
class_name GolfBall


## Dynamic friction subtracted from the body's velocity on each physics step.
@export var physics_friction: float
## The maximum number of bounces that the collision algorithm will consider in a single physics step.
@export var physics_max_bounces: float
## A multiplier applied to the body's velocity every time it collides with something.
@export var physics_bounce_coefficient: float
## The scene to instantiate to play the collision sound
@export var collision_sound: PackedScene
## Curve mapping relative putt power to putt sound volume.
@export var collision_volume_db: Curve
## The velocity at which the maximum volume of [member collision_volume_db] is played.
@export var collision_volume_max_velocity: float
## Emitted when the ball enters the hole.
signal entered_hole(strokes: int)

## How many strokes have been performed so far.
var strokes: int = 0
## Whether the ball has entered the hole.
var in_hole: bool = false

@onready var putt_controller: PuttController = $"PuttController"
@onready var hole_controller: HoleController = $"HoleController"
@onready var hole_sound: AudioStreamPlayer2D = $"HoleSound"
@onready var player_label: Label = $"PlayerLabel"


## The name of the player represented by this scene.
var player_name: String = "Player":
	get:
		return player_name
	set(value):
		player_name = value
		player_label.text = value
		
## The color of the player represented by this scene.
var player_color: Color = Color.WHITE:
	get:
		return player_color
	set(value):
		player_color = value
		modulate = value


func _on_putt(putt_vector: Vector2):
	strokes += 1
	velocity += putt_vector


func do_movement(delta: float):
	# How much the body should move in this physics step.
	var movement = velocity * delta
	# How many times the body collided in the current physics step.
	var bounces: int = 0
	# While the body should still move some space, and it isn't stuck in a perpetual loop of bouncing...
	while movement.length() > 0.0 and bounces < physics_max_bounces:
		# Try to move!
		var collision: KinematicCollision2D = move_and_collide(movement)
		# If the body did not collide and performed its full movement, we're done!
		if not collision:
			break
		# Let's try to handle the collision properly
		bounces += 1
		# Determine the normal of the collision (the direction the body should be pushed back in)
		var collision_normal = collision.get_normal()
		# Play the collision sound
		if bounces == 1:
			# Determine with how much speed the body collided
			var collision_velocity = -collision_normal.dot(velocity)
			# Create a new sound instance
			var collision_sound_instance: AudioStreamPlayer2D = collision_sound.instantiate()
			# Set the sound volume based on the relative collision velocity
			collision_sound_instance.volume_db = min(0, collision_volume_db.sample(collision_velocity / collision_volume_max_velocity))
			# Add the sound to the SceneTree so it starts playing
			$"..".add_child(collision_sound_instance)
			# Set the sound's global position to the current global position of the body
			collision_sound_instance.global_position = global_position
		# Change the velocity adequately
		velocity = velocity.bounce(collision_normal)
		# Reflect the remaining movement
		movement = collision.get_remainder().bounce(collision_normal)
	# If we collided with something in this step, we need to apply the bounce coefficient
	if bounces > 0:
		velocity *= physics_bounce_coefficient


func apply_friction(delta):
	var new_velocity_length = max(0.0, velocity.length() - physics_friction * delta)
	velocity = velocity.normalized() * new_velocity_length


func check_has_stopped() -> bool:
	return velocity.length() == 0.0


func check_has_entered_hole() -> bool:
	return check_has_stopped() and hole_controller.over_hole


func enter_hole():
	in_hole = true
	visible = false
	hole_sound.play()
	entered_hole.emit(strokes)
	print("[GolfBall] Entered hole in: ", strokes)


func _physics_process(delta):
	if not in_hole:
		do_movement(delta)
		apply_friction(delta)
		if check_has_entered_hole():
			enter_hole()
		if check_has_stopped():
			putt_controller.can_putt = true
