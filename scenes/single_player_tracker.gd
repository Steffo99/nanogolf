extends Node
class_name SinglePlayerTracker


signal identity_updated(player_name: String, player_color: Color)


## Whether the peer is connected or not.
var peer_connected: bool = true

## The player's name.
var player_name: String = "Player"

## The player's color.
var player_color: Color = Color.WHITE

## This player's score, with an item per hole played.
var strokes_per_hole: Array[int] = []


@rpc("authority", "call_local", "reliable")
func update_identity(new_player_name: String, new_player_color: Color):
	player_name = new_player_name
	player_color = new_player_color
	identity_updated.emit(player_name, player_color)

func notify_identity(peer_id: int):
	Log.peer(self, "Notifying of our identity: " + str(peer_id))
	update_identity.rpc_id(peer_id, player_name, player_color)
