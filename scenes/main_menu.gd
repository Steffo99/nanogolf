extends Control
class_name MainMenu


enum MenuStage {
	NAME_INPUT = 1,
	COLOR_PICKER = 2,
	SERVER_MENU = 3,
}

var current_stage: MenuStage:
	get:
		return current_stage
	set(value):
		if value == current_stage:
			return
		match current_stage:
			MenuStage.NAME_INPUT:
				deinit_name_input()
			MenuStage.COLOR_PICKER:
				deinit_color_picker()
			MenuStage.SERVER_MENU:
				deinit_server_menu()
		current_stage = value
		match value:
			MenuStage.NAME_INPUT:
				init_name_input()
			MenuStage.COLOR_PICKER:
				init_color_picker()
			MenuStage.SERVER_MENU:
				init_server_menu()


@onready var panel_parent: Container = $"VBoxContainer"


var player_name: String = ""
const name_input_scene = preload("res://scenes/player_name_input.tscn")
var name_input_instance: PlayerNameInput = null

func init_name_input():
	name_input_instance = name_input_scene.instantiate()
	name_input_instance.name_confirmed.connect(_on_name_confirmed)
	panel_parent.add_child(name_input_instance)

func deinit_name_input():
	name_input_instance.name_confirmed.disconnect(_on_name_confirmed)
	name_input_instance.queue_free()

func _on_name_confirmed(selected_name: String):
	player_name = selected_name
	current_stage = MenuStage.COLOR_PICKER


var player_color: Color = Color.WHITE
const color_picker_scene = preload("res://scenes/player_color_picker.tscn")
var color_picker_instance: PlayerColorPicker = null

func init_color_picker():
	color_picker_instance = color_picker_scene.instantiate()
	color_picker_instance.color_confirmed.connect(_on_color_confirmed)
	panel_parent.add_child(color_picker_instance)

func deinit_color_picker():
	color_picker_instance.color_confirmed.disconnect(_on_color_confirmed)
	color_picker_instance.queue_free()

func _on_color_confirmed(selected_color: Color):
	player_color = selected_color
	current_stage = MenuStage.SERVER_MENU


const server_menu_scene = preload("res://scenes/server_options_menu.tscn")
var server_menu_instance: ServerOptionsMenu = null

func init_server_menu():
	server_menu_instance = server_menu_scene.instantiate()
	server_menu_instance.hosting_confirmed.connect(_on_hosting_confirmed)
	server_menu_instance.connecting_confirmed.connect(_on_connecting_confirmed)
	panel_parent.add_child(server_menu_instance)

func deinit_server_menu():
	server_menu_instance.queue_free()

func _on_hosting_confirmed(port: int):
	push_warning("TODO")
	current_stage = MenuStage.NAME_INPUT

func _on_connecting_confirmed(address: String, port: int):
	push_warning("TODO")
	current_stage = MenuStage.NAME_INPUT


func _ready():
	current_stage = MenuStage.NAME_INPUT
