extends Node
class_name Main


@onready var interface_instance: MarginContainer = $"Interface"

const main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
var main_menu_instance: MainMenu = null

func init_main_menu():
	main_menu_instance = main_menu_scene.instantiate()
	main_menu_instance.room_created.connect(_on_room_created)
	main_menu_instance.room_joined.connect(_on_room_joined)
	interface_instance.add_child(main_menu_instance)


func _on_room_created(server: ENetMultiplayerPeer, client: ENetMultiplayerPeer):
	print(server, client)

func _on_room_joined(client: ENetMultiplayerPeer):
	print(client)


func _ready():
	init_main_menu()


