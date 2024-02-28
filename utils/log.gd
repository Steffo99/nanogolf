extends Node
class_name Log


static func peer(this: Node, string: String):
	print("{", this.multiplayer.multiplayer_peer.get_unique_id(), "} ", string)
