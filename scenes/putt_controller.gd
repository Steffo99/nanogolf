extends Node2D
class_name PuttController

## The maximum impulse that a putt can have.
@export var putt_max_impulse: float
## How many game units a pixel of screen mouse movement corresponds to. 
@export var putt_drag_scale: float
## Length multiplier of the putt ghost
@export var putt_ghost_scale: float
## Curve mapping relative putt impulse to putt sound volume.
@export var putt_volume: Curve
## Emitted when a putt has happened.
signal putt(putt_vector: Vector2)

@onready var sprite: Sprite2D = $Sprite
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var sprite_texture_width: float = sprite.texture.get_width()

var is_putting: bool = false
var putt_start_point: Vector2

var can_putt: bool = false:
	get:
		return can_putt
	set(value):
		can_putt = value
		if not value:
			is_putting = false


func _input(event: InputEvent):
	if can_putt:
		if event is InputEventMouseButton:
			if event.pressed:
				if not is_putting:
					start_putt(event.position)
				else:
					push_warning("Attempted to start putt while another was in progress.")
			else:
				if is_putting:
					end_putt(event.position)
				else:
					push_warning("Attempted to end putt while none was in progress.")
			if is_putting:
				update_putt_ghost(compute_putt(event.position, putt_start_point))
		if event is InputEventMouseMotion:
			if is_putting:
				update_putt_ghost(compute_putt(event.position, putt_start_point))


func update_putt_ghost(putt_vector: Vector2):
	sprite.rotation = putt_vector.angle()
	sprite.scale.x = putt_vector.length() * putt_ghost_scale / sprite_texture_width
	sprite.position = position - putt_vector * putt_ghost_scale * 0.5


func compute_putt(start_position: Vector2, end_position: Vector2) -> Vector2:
	var vector: Vector2 = -(end_position - start_position)
	vector *= putt_drag_scale
	if vector.length() > putt_max_impulse:
		vector = vector.normalized() * putt_max_impulse
	return vector


func start_putt(start_position: Vector2):
	visible = true
	is_putting = true
	putt_start_point = start_position


func end_putt(end_position: Vector2):
	visible = false
	is_putting = false
	can_putt = false
	var putt_vector = compute_putt(putt_start_point, end_position)
	putt.emit(putt_vector)
	play_putt_sound(putt_vector)


func play_putt_sound(putt_vector: Vector2):
	var putt_impulse: float = putt_vector.length()
	sound.volume_db = putt_volume.sample(putt_impulse / putt_max_impulse)
	sound.play()
