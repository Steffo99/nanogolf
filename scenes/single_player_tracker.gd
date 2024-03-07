extends MultiplayerSynchronizer
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
