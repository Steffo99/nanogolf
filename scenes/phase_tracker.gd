extends Node
class_name PhaseTracker


## Phases of play of the game.
enum Phase {
	## The game is currently gathering players in a lobby.
	LOBBY,
	## The game is currently running.
	PLAYING,
	## The game has ended.
	ENDED,
}

## The phase the game is currently in.
var phase: Phase = Phase.LOBBY

## Change the current game phase everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_set_phase(value: Phase):
	var old: Phase = phase
	if old != value:
		Log.peer(self, "Changing phase to: %s" % value)
		phase = value
		phase_changed.emit(old, value)

## Ask the server which phase the game is currently in.
@rpc("any_peer", "call_local", "reliable")
func rpc_query_phase():
	if multiplayer.is_server():
		rpc_set_phase.rpc(phase)

## Emitted when the phase changes on the local scene because of [method rpc_set_phase].
signal phase_changed(old: Phase, new: Phase)
