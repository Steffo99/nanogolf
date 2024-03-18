extends Node
class_name LevelManager



@export_category("References")

## The [LevelPlaylist] to use to load [GolfLevel]s from.
@export var playlist: LevelPlaylist = null

## The [PlayerNodeDirectory] to use to determine which players to spawn on clients.
@export var player_dir: PlayerNodeDirectory = null



## Emitted when a level has been completed.
signal level_completed(level: GolfLevel)



## The blank [GolfLevel] to initialize on clients.
const base_scene: PackedScene = preload("res://scenes/golf_level.tscn")

## The currently instantiated [GolfLevel].
var level: GolfLevel = null

## The next scene to use as [field target].
##
## Should be null on everything that's not the server.
var next: PackedScene = null

## The currently instantiated target [GolfLevel].
##
## Should be null on everything that's not the server.
var target: GolfLevel = null


## Destroy the current [field level].
func destroy_level() -> void:
	Log.peer(self, "Emitting level_destroying signal...")
	level_destroying.emit(level)

	Log.peer(self, "Queueing the free of the level and removing references...")
	remove_child(level)
	level.queue_free()
	level = null

	Log.peer(self, "Emitting level_destroyed signal...")
	level_destroyed.emit()

## Emitted when the current level is about to be destroyed.
signal level_destroying(level: GolfLevel)

## Emitted when the current level has been destroyed.
signal level_destroyed


## Advance the [field playlist] and return the next level to play.
func determine_next_level() -> void:
	Log.peer(self, "Determining the next level...")
	next = playlist.advance()

	Log.peer(self, "Determined the next level: %s" % next)
	level_determined.emit(next)

	if next == null:
		Log.peer(self, "Playlist is complete.")
		playlist_complete.emit(playlist)

## Emitted when the next level has been determined by calling [LevelPlaylist.advance].
signal level_determined(scene: PackedScene)

## Emitted when all levels in the [field playlist] have been exausted.
signal playlist_complete(playlist: LevelPlaylist)


## Instantiate and setup a copy of the [field base_scene].
func initialize_level() -> void:
	Log.peer(self, "Instantiating level template...")
	level = base_scene.instantiate()

	Log.peer(self, "Configuring level variables...")
	level.player_dir = player_dir

	Log.peer(self, "Connecting level signals...")
	level.level_completed.connect(_on_level_completed)

	Log.peer(self, "Adding level to the scene tree...")
	add_child(level, true)

	Log.peer(self, "Emitting level_initialized signal...")
	level_initialized.emit(level)

## Emitted when a copy of [field base_scene] has been initialized by [method initialize_level].
signal level_initialized(level: GolfLevel)


## Instantiate a copy of the given target [GolfLevel].
func init_target() -> void:
	Log.peer(self, "Instantiating level targets...")
	level.target = next.instantiate()
	
	Log.peer(self, "Emitting target_initialized signal...")
	target_initialized.emit(level.target)

## Emitted when a copy of the target level has been initialized by [method init_target].
signal target_initialized(level: GolfLevel)


## Replicate the [method target] onto the [method level] of all currently connected clients if no peer_id is specified, or to only that client if a peer_id is specified.
func build_level(peer_id: int = 0) -> void:
	Log.peer(self, "Building level...")
	level.build(peer_id)

	Log.peer(self, "Emitting level_built signal...")
	level_built.emit(level)

## Emitted on the server when it has finished sending out RPCs for the [method GolfLevel.build] of the [field target] level.
signal level_built(level: GolfLevel)


## Send the current level to a given client.
func sync_level(peer_id: int = 0) -> void:
	Log.peer(self, "Repeating the current level to: %d" % peer_id)
	if level:
		if peer_id > 0:
			rpc_wipe_level.rpc_id(peer_id)
		else:
			rpc_wipe_level.rpc()
		build_level(peer_id)


## Add a new player to the current level.
func add_player(playernode: PlayerNode):
	Log.peer(self, "Adding a new player to the level in progress...")
	if level != null:
		level.build_new_ball(playernode.player_name)


## Advance to the next level.
func next_level() -> void:
	Log.peer(self, "Advancing to the next level...")
	determine_next_level()
	if next != null:
		rpc_wipe_level.rpc()
		init_target()
		build_level()
	else:
		rpc_destroy_level.rpc()


## Clear the current level on all clients and prepare to build a new one.
@rpc("authority", "call_local", "reliable")
func rpc_wipe_level():
	if level != null:
		destroy_level()
	initialize_level()

## Clear the current level on all clients.
@rpc("authority", "call_local", "reliable")
func rpc_destroy_level():
	if level != null:
		destroy_level()


## Emit [signal level_completed] everywhere.
@rpc("authority", "call_local", "reliable")
func rpc_level_completed() -> void:
	level_completed.emit(level)



func _on_level_completed() -> void:
	Log.peer(self, "Level completed!")
	rpc_level_completed.rpc()
	if is_multiplayer_authority():
		next_level()
