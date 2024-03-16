extends Node
class_name LevelManager



@export_category("References")

## The [LevelPlaylist] to use to load [GolfLevel]s from.
@export var playlist: LevelPlaylist = null

## The [PlayerNodeDirectory] to use to determine which players to spawn on clients.
@export var player_dir: PlayerNodeDirectory = null


## Emitted when the current level is about to be destroyed.
signal level_destroying(level: GolfLevel)

## Emitted when the next level has been determined by calling [LevelPlaylist.advance].
signal level_determined(scene: PackedScene)

## Emitted when the new level has been added to the tree, but not built.
signal level_created(level: GolfLevel)

## Emitted when a level has been completed.
signal level_completed(level: GolfLevel)

## Emitted when all levels in the [field playlist] have been exausted.
signal playlist_complete(playlist: LevelPlaylist)


## The blank [GolfLevel] to initialize on clients.
const base_scene: PackedScene = preload("res://scenes/golf_level.tscn")

## The currently instantiated [GolfLevel].
var level: GolfLevel = null


## Create the empty [GolfLevel] object everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_next_level():
	Log.peer(self, "Advancinng to the next level!")
	# Destroy the current level
	if level != null:
		Log.peer(self, "Destroying the current level: %s" % level)
		level_destroying.emit(level)
		level.queue_free()
		level = null
	# Determine the next level
	Log.peer(self, "Determining the next level...")
	var next = playlist.advance()
	Log.peer(self, "Determined the next level: %s" % next)
	level_determined.emit(next)
	## Make sure the playlist hasn't been exausted
	if next == null:
		Log.peer(self, "Playlist is complete, not doing anything.")
		playlist_complete.emit(playlist)
		return
	# Create the new level
	Log.peer(self, "Instantiating empty level template...")
	level = base_scene.instantiate()
	Log.peer(self, "Instantiated empty level template: %s" % level)
	# Configure the new level
	Log.peer(self, "Configuring level variables...")
	level.player_dir = player_dir
	level.level_completed.connect(_on_level_completed)
	if multiplayer.is_server():
		Log.peer(self, "Instantiating the target level scene...")
		level.target = next.instantiate()
		Log.peer(self, "Instantiated the target level scene: %s" % level.target)
	# Add the level to the tree
	Log.peer(self, "Adding level to the tree...")
	add_child(level, true)
	level_created.emit(level)
	# Start the replication
	if multiplayer.is_server():
		Log.peer(self, "Building level...")
		level.build()


func _on_level_completed() -> void:
	Log.peer(self, "Level completed!")
	level_completed.emit(level)
	if is_multiplayer_authority():
		rpc_next_level.rpc()
