extends Node
class_name PeerNode
## Node containing all possible RPCs callable by a non-identified peer.


## Identifies the peer as the player with the given name.
@rpc("authority", "reliable")  # Won't ever get called by server
func rpc_identify(player_name: String):
	if multiplayer.is_server():
		identified.emit(player_name)

## Emitted on the server when the peer with authority over this node calls [method rpc_identify].
signal identified(player_name: String)
