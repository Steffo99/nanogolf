extends PanelContainer
class_name PlayerColorPicker


signal color_confirmed(selected_color: Color)

var selected_color: Color = Color.WHITE:
	get:
		return selected_color
	set(value):
		selected_color = value
		preview_texture.modulate = value

@onready var preview_texture: TextureRect = $"Layout/PreviewContainer/PreviewTexture"


func _on_color_picker_color_changed(color: Color):
	selected_color = color

func _on_button_pressed():
	color_confirmed.emit(selected_color)
