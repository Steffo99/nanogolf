extends Node
class_name NetworkController


@export var port = 12345


func start_server() -> ENetMultiplayerPeer:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 32)
	return peer


func start_client() -> ENetMultiplayerPeer:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", port)
	return peer
