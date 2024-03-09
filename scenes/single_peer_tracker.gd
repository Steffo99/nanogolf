extends Node
class_name SinglePeerTracker

## Node representative of a single connected peer.
## 
## That specific peer must have authority over this node.
##
## Then, that authority is used to connect to a specific player.

@rpc("authority", "call_local", "reliable")
func takeover(player: SinglePlayerTracker):
	pass
