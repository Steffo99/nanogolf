extends Node
class_name LevelManager

## The blank [GolfLevel] to initialize on clients.
const base_scene: PackedScene = preload("res://scenes/golf_level.tscn")

## The [LevelPlaylist] to use to load [GolfLevel]s from.
@export var playlist: LevelPlaylist = null

## The [PlayerNodeDirectory] to use to determine which players to spawn on clients.
@export var player_dir: PlayerNodeDirectory = null


## The currently instantiated [GolfLevel].
var level: GolfLevel = null


## Create the empty [GolfLevel] object everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_next_level():
	# Destroy the current level
	if level != null:
		level.target.queue_free()
		player_dir.child_entered_tree.disconnect(level._on_playernode_created)
		level.queue_free()
		level = null
	# Create the new level
	level = base_scene.instantiate()
	level.player_dir = player_dir
	# Determine the next level
	if multiplayer.is_server():
		var target = playlist.advance().instantiate()
		level.target = target
		player_dir.child_entered_tree.connect(level._on_playernode_created)
	# Add the level to the tree
	add_child(level)
	# Start the replication
	if multiplayer.is_server():
		level.build()
