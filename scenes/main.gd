extends Node
class_name Main


@onready var scene_tree: SceneTree = get_tree()
@onready var interface_instance: MarginContainer = $"Interface"

const main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
var main_menu_instance: MainMenu = null

const game_scene: PackedScene = preload("res://scenes/game.tscn")
var server_game_instance: Game = null
var client_game_instance: Game = null

const lobby_menu_scene: PackedScene = preload("res://scenes/lobby_menu.tscn")
var lobby_menu_instance: LobbyMenu = null

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
	
	print("[Main] Creating server at: *:", server_port)
	var smp: SceneMultiplayer = SceneMultiplayer.new()
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_server(server_port)
	if error != OK or peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error(error)
		return
	
	scene_tree.set_multiplayer(smp, ^"/root/Main/Server")
	server_game_instance.init_signals()
	smp.set_multiplayer_peer(peer)

func deinit_server_game():
	server_game_instance.multiplayer.multiplayer_peer = null
	scene_tree.set_multiplayer(multiplayer, ^"/root/Main/Server")
	server_game_instance.queue_free()

func init_client_game(player_name: String, player_color: Color, server_address: String, server_port: int):
	client_game_instance = game_scene.instantiate()
	client_game_instance.name = "Client"
	add_child(client_game_instance, true)
	
	print("[Main] Creating client connecting to: ", server_address, ":", server_port)
	var smp = SceneMultiplayer.new()
	var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	var error: Error = peer.create_client(server_address, server_port)
	if error != OK or peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error(error)
		return
	
	scene_tree.set_multiplayer(smp, ^"/root/Main/Client")
	client_game_instance.init_signals()
	client_game_instance.local_player_name = player_name
	client_game_instance.local_player_color = player_color
	smp.set_multiplayer_peer(peer)

func deinit_client_game():
	client_game_instance.multiplayer.multiplayer_peer = null
	scene_tree.set_multiplayer(multiplayer, ^"/root/Main/Client")
	client_game_instance.queue_free()

func init_lobby_menu():
	lobby_menu_instance = lobby_menu_scene.instantiate()
	lobby_menu_instance.leave_confirmed.connect(_on_leave_confirmed)
	lobby_menu_instance.start_confirmed.connect(_on_start_confirmed)
	lobby_menu_instance.init_refs()
	client_game_instance.multiplayer.server_disconnected.connect(_on_leave_confirmed)
	client_game_instance.player_dir.child_entered_tree.connect(lobby_menu_instance.players_list._on_playernode_created)
	client_game_instance.player_dir.child_exiting_tree.connect(lobby_menu_instance.players_list._on_playernode_destroyed)
	client_game_instance.player_dir.playernode_name_changed.connect(lobby_menu_instance.players_list._on_playernode_name_changed)
	client_game_instance.player_dir.playernode_color_changed.connect(lobby_menu_instance.players_list._on_playernode_color_changed)
	client_game_instance.player_dir.playernode_possessed.connect(lobby_menu_instance.players_list._on_playernode_possessed)
	interface_instance.add_child(lobby_menu_instance)

func deinit_lobby_menu():
	client_game_instance.multiplayer.server_disconnected.disconnect(_on_leave_confirmed)
	client_game_instance.player_dir.child_entered_tree.disconnect(lobby_menu_instance.players_list._on_playernode_created)
	client_game_instance.player_dir.child_exiting_tree.disconnect(lobby_menu_instance.players_list._on_playernode_destroyed)
	client_game_instance.player_dir.playernode_name_changed.disconnect(lobby_menu_instance.players_list._on_playernode_name_changed)
	client_game_instance.player_dir.playernode_color_changed.disconnect(lobby_menu_instance.players_list._on_playernode_color_changed)
	client_game_instance.player_dir.playernode_possessed.disconnect(lobby_menu_instance.players_list._on_playernode_possessed)
	lobby_menu_instance.queue_free()

func _ready():
	init_main_menu()

func _on_hosting_confirmed(player_name: String, player_color: Color, server_port: int):
	deinit_main_menu()
	init_server_game(server_port)
	init_client_game(player_name, player_color, "127.0.0.1", server_port)
	init_lobby_menu()

func _on_connecting_confirmed(player_name: String, player_color: Color, server_address: String, server_port: int):
	deinit_main_menu()
	init_client_game(player_name, player_color, server_address, server_port)
	init_lobby_menu()

func _on_leave_confirmed():
	deinit_lobby_menu()
	deinit_client_game()
	if server_game_instance != null:
		deinit_server_game()
	init_main_menu()

func _on_start_confirmed():
	pass
