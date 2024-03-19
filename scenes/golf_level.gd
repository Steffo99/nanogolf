extends Node2D
class_name GolfLevel



@export_category("Level Data")

## Whether the [field camera] follows the active player or not.
@export var camera_follows_player: bool = false



@export_category("References")

## The [Camera2D] of this level.
@export var camera: Camera2D = null

## The [GolfTee] of this level.
@export var tee: GolfTee = null

## The [GolfHole] of this level.
@export var hole: GolfHole = null

## The [TileMap] of this level.
@export var map: TileMap = null



## If active, the [Timer] between emissions of [signal everyone_entered_hole] and [signal level_completed].
var complete_timer: Timer = null

## If on server, this variable indicates the [GolfLevel] to replicate.
##
## The [GolfLevel] in question should not be added to the scene tree, or it will cause problems on the client acting as server.
##
## On clients, this variable is ignored.
var target: GolfLevel = null


## The [PlayerNodeDirectory] to use to determine which players to spawn.
##
## It should be set on instantiation of a new [GolfLevel].
var player_dir: PlayerNodeDirectory = null


## The [PackedScene] to initialize as [TileMap].
const tilemap_scene: PackedScene = preload("res://scenes/golf_tilemap.tscn")

## The [PackedScene] to initialize as [GolfTee].
const tee_scene: PackedScene = preload("res://scenes/golf_tee.tscn")

## The [PackedScene] to initialize as [GolfHole].
const hole_scene: PackedScene = preload("res://scenes/golf_hole.tscn")

## The [PackedScene] to initialize as [Camera2D].
const camera_scene: PackedScene = preload("res://scenes/follow_camera.tscn")

## The [PackedScene] to initialize as [Timer] between emissions of [signal everyone_entered_hole] and [signal level_completed].
const complete_timer_scene: PackedScene = preload("res://scenes/complete_timer.tscn")


## Replicate the [field target] from the server to the clients via RPC.
func build(peer_id: int = 0) -> void:
	build_tilemap(peer_id)
	build_tilemap_cells(peer_id)
	build_tee(peer_id)
	build_existing_balls(peer_id)
	build_new_balls(peer_id)
	build_hole(peer_id)
	build_camera(peer_id)


## Replicate the [field map] of the [field target] to the remote [field map].
func build_tilemap(peer_id: int = 0) -> void:
	Log.peer(self, "Replicating map...")
	var tmap: TileMap = target.map
	if peer_id > 0:
		rpc_build_tilemap.rpc_id(peer_id, tmap.global_position, tmap.global_rotation, tmap.global_scale)
	else:
		rpc_build_tilemap.rpc(tmap.global_position, tmap.global_rotation, tmap.global_scale)

## Create the [field map].
@rpc("authority", "call_local", "reliable")
func rpc_build_tilemap(tposition: Vector2, trotation: float, tscale: Vector2):
	Log.peer(self, "Building map...")
	map = tilemap_scene.instantiate()
	map.global_position = tposition
	map.global_rotation = trotation
	map.global_scale = tscale
	add_child(map)


## Replicate the cells of [field target]'s [field map] to the remote [field map].
##
## The [field map] must be already created.
## 
## Only takes layer 0 into consideration.
func build_tilemap_cells(peer_id: int = 0) -> void:
	Log.peer(self, "Replicating map cells...")
	var tmap: TileMap = target.map
	const layer = 0
	for coords in tmap.get_used_cells(layer):
		var source_id: int = tmap.get_cell_source_id(0, coords)
		var atlas_coords: Vector2i = tmap.get_cell_atlas_coords(0, coords)
		var alternative_tile: int = tmap.get_cell_alternative_tile(0, coords)
		if peer_id > 0:
			rpc_build_tilemap_cell.rpc_id(peer_id, layer, coords, source_id, atlas_coords, alternative_tile)		
		else:
			rpc_build_tilemap_cell.rpc(layer, coords, source_id, atlas_coords, alternative_tile)

## Create a cell of [field map].
@rpc("authority", "call_local", "reliable")
func rpc_build_tilemap_cell(
	layer: int, 
	coords: Vector2i, 
	source_id: int, 
	atlas_coords: Vector2i = Vector2i(-1, -1), 
	alternative_tile: int = 0
):
	# Log.peer(self, "Building map cell: %s" % coords)
	map.set_cell(layer, coords, source_id, atlas_coords, alternative_tile)


## Replicate the [field tee] of the [field target] to the remote [field tee].
func build_tee(peer_id: int = 0) -> void:
	Log.peer(self, "Replicating tee...")
	var ttee: GolfTee = target.tee
	if peer_id > 0:
		rpc_build_tee.rpc_id(peer_id, ttee.global_position)
	else:
		rpc_build_tee.rpc(ttee.global_position)

## Create the [GolfTee] object.
@rpc("authority", "call_local", "reliable")
func rpc_build_tee(tposition: Vector2):
	Log.peer(self, "Building tee...")
	tee = tee_scene.instantiate()
	tee.global_position = tposition
	tee.everyone_entered_hole.connect(_on_everyone_entered_hole)
	add_child(tee)


## Replicate the currently connected players' [GolfBall]s to the remote [field tee].
func build_existing_balls(peer_id: int = 0) -> void:
	Log.peer(self, "Replicating existing golf balls...")
	for tball in tee.get_children():
		if peer_id > 0:
			rpc_build_ball.rpc_id(peer_id, tball.name, tball.position, tball.strokes, tball.in_hole)
		else:
			rpc_build_ball.rpc(tball.name, tball.position, tball.strokes, tball.in_hole)

func build_new_balls(peer_id: int = 0) -> void:
	Log.peer(self, "Replicating new golf balls...")
	for playernode in player_dir.get_children():
		if peer_id > 0:
			rpc_build_ball.rpc_id(peer_id, playernode.player_name, Vector2.ZERO, 0, false)
		else:
			rpc_build_ball.rpc(playernode.player_name, Vector2.ZERO, 0, false)

## Create the specified player's [GolfBall] at the remote [field tee].
func build_new_ball(player_name: String, peer_id: int = 0) -> void:
	Log.peer(self, "Replicating new golf ball for: %s" % player_name)
	if peer_id > 0:
		rpc_build_ball.rpc_id(peer_id, player_name, Vector2.ZERO, 0, false)
	else:
		rpc_build_ball.rpc(player_name, Vector2.ZERO, 0, false)

## Create and initialize a [GolfBall] for a single [PlayerNode] with the given name.
@rpc("authority", "call_local", "reliable")
func rpc_build_ball(player_name: String, tposition: Vector2, tstrokes: int, thole: bool):
	var playernode: PlayerNode = player_dir.get_playernode(player_name)
	var ball: GolfBall = tee.get_golfball(playernode)
	if ball == null:
		Log.peer(self, "Building golf ball for: %s" % player_name)
		ball = tee.spawn(playernode, tposition, tstrokes, thole)
	else:
		Log.peer(self, "Not building duplicate golf ball for: %s" % player_name)


## Replicate the [field hole] of the [field target] to the remote [field hole].
func build_hole(peer_id: int = 0) -> void:
	Log.peer(self, "Replicating hole...")
	var thole: GolfHole = target.hole
	if peer_id > 0:
		rpc_build_hole.rpc_id(peer_id, thole.global_position, thole.global_scale)
	else:
		rpc_build_hole.rpc(thole.global_position, thole.global_scale)

## Create the [GolfHole] object.
@rpc("authority", "call_local", "reliable")
func rpc_build_hole(tposition: Vector2, tscale: Vector2):
	Log.peer(self, "Building hole...")
	hole = hole_scene.instantiate()
	hole.global_position = tposition
	hole.global_scale = tscale
	add_child(hole)


## Replicate the [field camera] of the [field target] to the remote [field camera].
func build_camera(peer_id: int = 0) -> void:
	Log.peer(self, "Replicating camera...")
	var tcamera: FollowCamera = target.camera
	if peer_id > 0:
		rpc_build_camera.rpc_id(peer_id, tcamera.global_position, target.camera_follows_player)
	else:
		rpc_build_camera.rpc(tcamera.global_position, target.camera_follows_player)

## Create the [Camera2D] object.
@rpc("authority", "call_local", "reliable")
func rpc_build_camera(tposition: Vector2, tfocus: bool):
	if multiplayer.is_server():
		Log.peer(self, "Not building camera on the server.")
		return
	Log.peer(self, "Building camera...")
	camera = camera_scene.instantiate()
	camera.global_position = tposition
	if tfocus:
		# This supports only a single player per peer, for now.
		for child in player_dir.get_children():
			var playernode = child as PlayerNode
			if playernode.is_multiplayer_authority():
				var ctarget = tee.get_node(child.player_name)
				camera.target = ctarget
	add_child(camera)


func _ready() -> void:
	player_dir.local_playernode_possessed.connect(_on_local_playernode_possessed)
	if multiplayer.is_server():
		set_physics_process(false)
		hide()


func _on_everyone_entered_hole():
	Log.peer(self, "Everyone entered hole, starting end timer...")
	if is_multiplayer_authority():
		complete_timer = complete_timer_scene.instantiate()
		complete_timer.timeout.connect(_on_complete_timer_timeout)
		add_child(complete_timer)

func _on_complete_timer_timeout():
	Log.peer(self, "End timer has timed out, emitting level_completed signal...")
	complete_timer.queue_free()
	player_dir.rpc_push_reported_scores.rpc()
	level_completed.emit()

func _on_local_playernode_possessed(_old: int, _new: int, playernode: PlayerNode):
	if camera != null:
		var ctarget = tee.get_node(playernode.player_name)
		camera.target = ctarget


## Emitted on the server when it's time to change to the next level.
signal level_completed


func _on_tree_exiting() -> void:
	if target:
		target.queue_free()
		target = null
