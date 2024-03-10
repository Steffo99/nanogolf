extends Label
class_name PlayerLabel


func set_player_name(value: String):
	text = value

func set_player_color(value: Color):
	add_theme_color_override("font_color", value)

func set_possessed(value: int):
	if value == 1:
		modulate.a = 0.3
	else:
		modulate.a = 1.0
