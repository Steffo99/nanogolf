extends Camera2D
class_name FollowCamera


@export var target: Node2D


func _physics_process(_delta):
	if target:
		position = target.position
