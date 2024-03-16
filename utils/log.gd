extends Node
class_name Log


static func peer(this: Node, string: String):
	if this.multiplayer.multiplayer_peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		print("{", this.multiplayer.multiplayer_peer.get_unique_id(), "} [", str(this), "] ", string)
	else:
		print("{---} [", str(this), "] ", string)
