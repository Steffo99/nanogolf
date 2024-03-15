extends Camera2D
class_name FollowCamera


@export var target: Node2D = null


func _physics_process(_delta):
	if target != null:
		position = target.global_position
