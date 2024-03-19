extends Node2D
class_name PuttController



@export_category("References")

## The [Sprite2D] used to calculate [field sprite_texture_width] from.
@export var sprite: Sprite2D

## The [AudioStreamPlayer2D] to play when a putt happens.
@export var sound: AudioStreamPlayer2D



@export_category("Physics")

## The maximum impulse that a putt can have.
@export var putt_max_impulse: float



@export_category("Scale")

## How many game units a pixel of screen mouse movement corresponds to. 
@export var putt_drag_scale: float

## Length multiplier of the putt ghost
@export var putt_ghost_scale: float

## Curve mapping relative putt impulse to putt sound volume.
@export var putt_volume: Curve



## Emitted when a putt has happened.
signal putt(putt_vector: Vector2)


## The width in pixels that the putt ghost should have.
@onready var sprite_texture_width: float = sprite.texture.get_width()

## Whether a putt is currently in progress of not.
##
## If this is true, then [field drag_start_point] should contain a value.
var is_putting: bool = false

## The position on the screen where the putt has started.
var drag_start_point: Vector2

## Whether a putt can currently be performed or not.
var can_putt: bool = false:
	get:
		return can_putt
	set(value):
		can_putt = value
		if not value:
			is_putting = false


func _input(event: InputEvent):
	if can_putt:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
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
				update_putt_ghost(compute_putt(event.position, drag_start_point))
		if event is InputEventMouseMotion:
			if is_putting:
				update_putt_ghost(compute_putt(event.position, drag_start_point))


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
	drag_start_point = start_position


func end_putt(end_position: Vector2):
	visible = false
	is_putting = false
	can_putt = false
	var putt_vector = compute_putt(drag_start_point, end_position)
	putt.emit(putt_vector)
	play_putt_sound.rpc(putt_vector)

@rpc("authority", "call_local", "reliable")
func play_putt_sound(putt_vector: Vector2):
	if multiplayer.is_server():
		return
	var putt_impulse: float = putt_vector.length()
	sound.volume_db = putt_volume.sample(putt_impulse / putt_max_impulse)
	sound.play()

