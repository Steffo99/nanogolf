extends Node
class_name Main


@onready var scene_tree: SceneTree = get_tree()

@export var interface_instance: Interface

const main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn")
var main_menu_instance: MainMenu = null

const game_scene: PackedScene = preload("res://scenes/game.tscn")
var server_game_instance: Game = null
var client_game_instance: Game = null

const lobby_menu_scene: PackedScene = preload("res://scenes/lobby_menu.tscn")
var lobby_menu_instance: LobbyMenu = null

const game_hud_scene: PackedScene = preload("res://scenes/game_hud.tscn")
var game_hud_instance: GameHUD = null

const results_menu_scene: PackedScene = preload("res://scenes/results_menu.tscn")
var results_menu_instance: ResultsMenu = null


func init_main_menu() -> void:
	main_menu_instance = main_menu_scene.instantiate()
	main_menu_instance.hosting_confirmed.connect(_on_hosting_confirmed)
	main_menu_instance.connecting_confirmed.connect(_on_connecting_confirmed)
	interface_instance.add_child(main_menu_instance)

func deinit_main_menu() -> void:
	main_menu_instance.queue_free()
	main_menu_instance = null

func init_server_game(server_port: int) -> void:
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
	server_game_instance.lost_connection.connect(_on_lost_connection)
	smp.set_multiplayer_peer(peer)

func deinit_server_game() -> void:
	server_game_instance.multiplayer.multiplayer_peer = null
	scene_tree.set_multiplayer(null, ^"/root/Main/Server")
	server_game_instance.queue_free()
	server_game_instance = null

func init_client_game(player_name: String, player_color: Color, server_address: String, server_port: int) -> void:
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
	client_game_instance.phase_tracker.phase_changed.connect(_on_phase_changed)
	client_game_instance.lost_connection.connect(_on_lost_connection)
	smp.set_multiplayer_peer(peer)

func deinit_client_game() -> void:
	client_game_instance.multiplayer.multiplayer_peer = null
	scene_tree.set_multiplayer(null, ^"/root/Main/Client")
	client_game_instance.queue_free()
	client_game_instance = null

func init_lobby_menu() -> void:
	lobby_menu_instance = lobby_menu_scene.instantiate()
	lobby_menu_instance.init_refs()
	lobby_menu_instance.leave_confirmed.connect(_on_lost_connection)
	if server_game_instance:
		lobby_menu_instance.start_button.disabled = false
		lobby_menu_instance.start_confirmed.connect(server_game_instance._on_main_start_confirmed)
	client_game_instance.multiplayer.server_disconnected.connect(_on_lost_connection)
	client_game_instance.player_dir.child_entered_tree.connect(lobby_menu_instance.players_list._on_playernode_created)
	client_game_instance.player_dir.child_exiting_tree.connect(lobby_menu_instance.players_list._on_playernode_destroyed)
	client_game_instance.player_dir.playernode_name_changed.connect(lobby_menu_instance.players_list._on_playernode_name_changed)
	client_game_instance.player_dir.playernode_color_changed.connect(lobby_menu_instance.players_list._on_playernode_color_changed)
	client_game_instance.player_dir.playernode_possessed.connect(lobby_menu_instance.players_list._on_playernode_possessed)
	interface_instance.add_child(lobby_menu_instance)

func deinit_lobby_menu() -> void:
	lobby_menu_instance.leave_confirmed.disconnect(_on_lost_connection)
	if server_game_instance:
		lobby_menu_instance.start_confirmed.disconnect(server_game_instance._on_main_start_confirmed)
	client_game_instance.multiplayer.server_disconnected.disconnect(_on_lost_connection)
	client_game_instance.player_dir.child_entered_tree.disconnect(lobby_menu_instance.players_list._on_playernode_created)
	client_game_instance.player_dir.child_exiting_tree.disconnect(lobby_menu_instance.players_list._on_playernode_destroyed)
	client_game_instance.player_dir.playernode_name_changed.disconnect(lobby_menu_instance.players_list._on_playernode_name_changed)
	client_game_instance.player_dir.playernode_color_changed.disconnect(lobby_menu_instance.players_list._on_playernode_color_changed)
	client_game_instance.player_dir.playernode_possessed.disconnect(lobby_menu_instance.players_list._on_playernode_possessed)
	lobby_menu_instance.queue_free()
	lobby_menu_instance = null

func init_game_hud() -> void:
	game_hud_instance = game_hud_scene.instantiate()
	client_game_instance.level_manager.level_completed.connect(game_hud_instance._on_level_completed)
	client_game_instance.player_dir.playernode_name_changed.connect(game_hud_instance._on_playernode_name_changed)
	client_game_instance.player_dir.playernode_color_changed.connect(game_hud_instance._on_playernode_color_changed)
	client_game_instance.player_dir.playernode_possessed.connect(game_hud_instance._on_playernode_possessed)
	client_game_instance.player_dir.playernode_score_reported.connect(game_hud_instance._on_playernode_score_reported)
	client_game_instance.player_dir.playernode_scores_changed.connect(game_hud_instance._on_playernode_scores_changed)
	client_game_instance.player_dir.playernode_putt_performed.connect(game_hud_instance._on_playernode_putt_performed)
	interface_instance.add_child(game_hud_instance)

func deinit_game_hud() -> void:
	client_game_instance.level_manager.level_completed.disconnect(game_hud_instance._on_level_completed)
	client_game_instance.player_dir.playernode_name_changed.disconnect(game_hud_instance._on_playernode_name_changed)
	client_game_instance.player_dir.playernode_color_changed.disconnect(game_hud_instance._on_playernode_color_changed)
	client_game_instance.player_dir.playernode_possessed.disconnect(game_hud_instance._on_playernode_possessed)
	client_game_instance.player_dir.playernode_score_reported.disconnect(game_hud_instance._on_playernode_score_reported)
	client_game_instance.player_dir.playernode_scores_changed.disconnect(game_hud_instance._on_playernode_scores_changed)
	client_game_instance.player_dir.playernode_putt_performed.disconnect(game_hud_instance._on_playernode_putt_performed)
	game_hud_instance.queue_free()
	game_hud_instance = null

func init_results_menu() -> void:
	results_menu_instance = results_menu_scene.instantiate()
	results_menu_instance.player_dir = client_game_instance.player_dir
	results_menu_instance.leave_confirmed.connect(_on_lost_connection)
	interface_instance.add_child(results_menu_instance)

func deinit_results_menu() -> void:
	results_menu_instance.queue_free()
	results_menu_instance = null


func _ready() -> void:
	init_main_menu()

func _on_hosting_confirmed(player_name: String, player_color: Color, server_port: int) -> void:
	deinit_main_menu()
	init_server_game(server_port)
	init_client_game(player_name, player_color, "127.0.0.1", server_port)
	init_lobby_menu()

func _on_connecting_confirmed(player_name: String, player_color: Color, server_address: String, server_port: int) -> void:
	deinit_main_menu()
	init_client_game(player_name, player_color, server_address, server_port)
	init_lobby_menu()

func _on_lost_connection() -> void:
	print("[Main] On lost connection...")
	if lobby_menu_instance != null:
		deinit_lobby_menu()
	if game_hud_instance != null:
		deinit_game_hud()
	if results_menu_instance != null:
		deinit_results_menu()
	if client_game_instance != null:
		deinit_client_game()
	if server_game_instance != null:
		deinit_server_game()
	init_main_menu()

func _on_phase_changed(old: PhaseTracker.Phase, new: PhaseTracker.Phase) -> void:
	# First, deinitialize the current interface
	match old:
		PhaseTracker.Phase.LOBBY:
			deinit_lobby_menu()
		PhaseTracker.Phase.PLAYING:
			deinit_game_hud()
		PhaseTracker.Phase.ENDED:
			deinit_results_menu()
	# Then, initialize the new one
	match new:
		PhaseTracker.Phase.LOBBY:
			init_lobby_menu()
		PhaseTracker.Phase.PLAYING:
			init_game_hud()
		PhaseTracker.Phase.ENDED:
			init_results_menu()
