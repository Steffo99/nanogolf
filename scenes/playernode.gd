extends Node
class_name PlayerNode


## The name of the player represented by this node.
var player_name: String

## The color of the player represented by this node.
var player_color: Color

## Change the [field player_name] everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_set_name(value: String):
	if player_name != value:
		var old_value: String = player_name
		player_name = value
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


## Emitted when the name changes on the local scene because of [method rpc_set_name].
signal name_changed(old: String, new: String)

## Emitted when the color changes on the local scene because of [method rpc_set_color].
signal color_changed(old: Color, new: Color)

## Emitted when the multiplayer authority of this [Node] is changed via [method possess].
signal possessed(old: int, new: int)
