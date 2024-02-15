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

@onready var putt_controller: PuttController = $"PuttController"


func _on_putt(putt_vector: Vector2):
	velocity += putt_vector


func do_movement(movement: Vector2):
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
			print(collision_velocity)
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


func _physics_process(delta):
	do_movement(velocity * delta)
	var new_velocity_length = max(0.0, velocity.length() - physics_friction)
	velocity = velocity.normalized() * new_velocity_length
	if new_velocity_length == 0.0:
		putt_controller.can_putt = true
