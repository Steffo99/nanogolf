extends Node
class_name PlayerNode


## Remove problematic characters from the player's name
static func sanitize_player_name(s: String) -> String:
	return s.replace("/", "_").replace("*", "_").replace(" ", "_")


## The name of the player represented by this node.
var player_name: String

## The color of the player represented by this node.
var player_color: Color

## The scores of the player in all holes.
var hole_scores: Array = []

## Change the [field player_name] everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_set_name(value: String):
	if player_name != value:
		var old_value: String = player_name
		player_name = PlayerNode.sanitize_player_name(value)
		name = PlayerNode.sanitize_player_name(value)
		name_changed.emit(old_value, value)

## Change the [field player_color] everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_set_color(value: Color):
	if player_color != value:
		var old_value: Color = player_color
		player_color = value
		color_changed.emit(old_value, value)

## Change the multiplayer authority on the local client.
##
## Used by [PlayerNodeDirectory], provided here for the purpose of signal emission.
func possess(value: int) -> void:
	var old_value: int = get_multiplayer_authority()
	if old_value != value:
		set_multiplayer_authority(value)
		possessed.emit(old_value, value)

## Prompt the multiplayer authority for this node to call [method rpc_set_name] again with the current value.
##
## Used to repeat [field player_name] to new peers.
@rpc("any_peer", "call_local", "reliable")
func rpc_query_name():
	if is_multiplayer_authority():
		rpc_set_name.rpc(player_name)

## Prompt the multiplayer authority for this node to call [method rpc_set_color] again with the current value.
##
## Used to repeat [field player_color] to new peers.
@rpc("any_peer", "call_local", "reliable")
func rpc_query_color():
	if is_multiplayer_authority():
		rpc_set_color.rpc(player_color)


## Add a new score entry to the [field hole_scores].
func report_score(strokes: int) -> void:
	assert(is_multiplayer_authority())
	rpc_report_score.rpc(strokes)
	var tscores = hole_scores.duplicate(true)
	tscores.push_back(strokes)
	rpc_set_scores.rpc(tscores)

## Emit [signal score_reported] everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_report_score(strokes: int):
	score_reported.emit(strokes)


## Change the [field hole_scores] everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_set_scores(value: Array):
	var old_value: Array = hole_scores
	if old_value != value:  # How does this behave?
		hole_scores = value
		scores_changed.emit(old_value, value)


## Prompt the multiplayer authority for this node to call [method rpc_set_scores] again with the current value.
##
## Used to repeat [field hole_scores] to new peers.
@rpc("any_peer", "call_local", "reliable")
func rpc_query_scores():
	if is_multiplayer_authority():
		rpc_set_scores.rpc(hole_scores)



## Emitted when the name changes on the local scene because of [method rpc_set_name].
signal name_changed(old: String, new: String)

## Emitted when the color changes on the local scene because of [method rpc_set_color].
signal color_changed(old: Color, new: Color)

## Emitted when the multiplayer authority of this [Node] is changed via [method possess].
signal possessed(old: int, new: int)

## Emitted when a new hole score has been reported.
signal score_reported(strokes: int)

## Emitted when the hole scores have changed because of [method rpc_set_scores].
signal scores_changed(old: Array, new: Array)
