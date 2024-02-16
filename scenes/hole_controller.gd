extends Area2D
class_name HoleController


var over_hole: bool = false


func _on_area_entered(area: Area2D):
	if area is GolfHole:
		over_hole = true


func _on_area_exited(area: Area2D):
	if area is GolfHole:
		over_hole = false
