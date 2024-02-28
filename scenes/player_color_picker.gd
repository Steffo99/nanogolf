extends PanelContainer
class_name PlayerColorPicker


signal color_confirmed(selected_color: Color)

@onready var color_picker: ColorPicker = $"Layout/ColorPicker"
@onready var preview_texture: TextureRect = $"Layout/PreviewContainer/PreviewTexture"


func _on_color_picker_color_changed(color: Color):
	preview_texture.modulate = color

func _on_button_pressed():
	color_confirmed.emit(color_picker.color)
