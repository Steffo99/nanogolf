extends MultiplayerSynchronizer
class_name SinglePlayerTracker

## Emitted when the peer represented by this object connects.
signal peer_has_connected

## Emitted when the peer represented by this object connects.
signal peer_has_disconnected


## The peer ID that this object represents.
var peer_id: int = 0

## Whether the peer is connected or not.
var peer_connected: bool = false:
	get:
		return peer_connected
	set(value):
		var pvalue = peer_connected
		peer_connected = value
		if value != pvalue:
			if value:
				peer_has_connected.emit()
			else:
				peer_has_disconnected.emit()

## The player's name.
var player_name: String = "Player"

## The player's color.
var player_color: Color = Color.WHITE

## This player's score, with an item per hole played.
var strokes_per_hole: Array[int] = []
