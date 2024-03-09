extends Node
class_name SinglePlayerTracker

## Node representative of a player connected to the room.
##
## The peer of the player this node represents has authority over it.

## The player's name.
var player_name: String = "Player"

## The player's color.
var player_color: Color = Color.WHITE

## Whether this player is currently connected or not.
var player_connected: bool = false

## Change the name of this player.
@rpc("authority", "call_local", "reliable")
func set_player_name(value: String):
	player_name = value

## Change the color of this player.
@rpc("authority", "call_local", "reliable")
func set_player_color(value: Color):
	player_color = value

## Ask the authority for this player to repeat the player's name.
@rpc("any_peer", "call_local", "reliable")
func query_player_name():
	if is_multiplayer_authority():
		set_player_name.rpc(player_name)

## Ask the authority for this player to repeat the player's color.
@rpc("any_peer", "call_local", "reliable")
func query_player_color():
	if is_multiplayer_authority():
		set_player_color.rpc(player_color)
