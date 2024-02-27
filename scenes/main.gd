extends Node
class_name Main


@onready var scene_tree: SceneTree = get_tree()
@onready var interface_instance: MarginContainer = $"Interface"

const main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
var main_menu_instance: MainMenu = null

const game_scene: PackedScene = preload("res://scenes/game.tscn")
var server_game_instance: Game = null
var client_game_instance: Game = null


func init_main_menu():
	main_menu_instance = main_menu_scene.instantiate()
	main_menu_instance.hosting_confirmed.connect(_on_hosting_confirmed)
	main_menu_instance.connecting_confirmed.connect(_on_connecting_confirmed)
	interface_instance.add_child(main_menu_instance)

func deinit_main_menu():
	main_menu_instance.queue_free()

func init_server_game(server_port: int):
	server_game_instance = game_scene.instantiate()
	server_game_instance.name = "Server"
	add_child(server_game_instance, true)
	
	server_game_instance.init_signals()
	
	print("[Main] Creating server at: *:", server_port)
	var smp: SceneMultiplayer = SceneMultiplayer.new()
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(server_port)
	if error != OK or peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error(error)
		return
	
	scene_tree.set_multiplayer(smp, ^"/root/Main/Server")
	smp.set_multiplayer_peer(peer)

func deinit_server_game():
	var smp: SceneMultiplayer = scene_tree.get_multiplayer(^"/root/Main/Server")
	smp.multiplayer_peer.close()
	smp.multiplayer_peer = null
	scene_tree.set_multiplayer(multiplayer, ^"/root/Main/Server")
	server_game_instance.queue_free()

func init_client_game(player_name: String, player_color: Color, server_address: String, server_port: int):
	client_game_instance = game_scene.instantiate()
	client_game_instance.name = "Client"
	add_child(client_game_instance, true)
	
	client_game_instance.init_signals()
	
	print("[Main] Creating client connecting to: ", server_address, ":", server_port)
	var smp = SceneMultiplayer.new()
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(server_address, server_port)
	if error != OK or peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error(error)
		return
	
	scene_tree.set_multiplayer(smp, ^"/root/Main/Client")
	smp.set_multiplayer_peer(peer)

func deinit_client_game():
	var smp: SceneMultiplayer = scene_tree.get_multiplayer(^"/root/Main/Server")
	smp.multiplayer_peer.close()
	smp.multiplayer_peer = null
	scene_tree.set_multiplayer(multiplayer, ^"/root/Main/Client")
	client_game_instance.queue_free()


func _ready():
	init_main_menu()

func _on_hosting_confirmed(player_name: String, player_color: Color, server_port: int):
	deinit_main_menu()
	init_server_game(server_port)
	# init_client_game(player_name, player_color, "127.0.0.1", server_port)

func _on_connecting_confirmed(player_name: String, player_color: Color, server_address: String, server_port: int):
	deinit_main_menu()
	init_client_game(player_name, player_color, server_address, server_port)
