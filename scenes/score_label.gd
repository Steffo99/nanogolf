extends RichTextLabel
class_name ScoreLabel


func set_partial(value: int):
	if value == -1:
		text = "[code][right]-[/right][/code]"
	else:
		text = "[code][right]%s[/right][/code]" % value

func set_total(value: int):
	if value == -1:
		text = "[code][right]-[/right][/code]"
	else:
		text = "[code][right][b]%s[/b][/right][/code]" % value

func set_player_color(value: Color):
	modulate.r = value.r
	modulate.g = value.g
	modulate.b = value.b

func set_possessed(value: int):
	if value == 1:
		modulate.a = 0.3
	else:
		modulate.a = 1.0
