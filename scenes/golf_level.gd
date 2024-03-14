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


## If on server, this variable indicates the [GolfLevel] to replicate on clients.
##
## The [GolfLevel] in question should not be added to the scene tree, or it will cause problems on the client acting as server.
##
## On clients, this variable is ignored.
var target: GolfLevel = null


## The [PlayerNodeDirectory] to use to determine which players to spawn on clients.
##
## It should be set on instantiation of a new [GolfLevel].
var player_dir: PlayerNodeDirectory = null


## The [PackedScene] to initialize on clients as [TileMap].
const tilemap_scene: PackedScene = preload("res://scenes/golf_tilemap.tscn")

## The [PackedScene] to initialize on clients as [GolfTee].
const tee_scene: PackedScene = preload("res://scenes/golf_tee.tscn")

## The [PackedScene] to initialize on clients as [GolfHole].
const hole_scene: PackedScene = preload("res://scenes/golf_hole.tscn")

## The [PackedScene] to initialize on clients as [Camera2D].
const camera_scene: PackedScene = preload("res://scenes/follow_camera.tscn")


## Replicate the [field target] from the server to the clients via RPC.
func build() -> void:
	build_tilemap()
	build_tilemap_cells()
	build_tee()
	build_hole()
	build_camera()


## Replicate the [field map] of the [field target] to the remote [field map].
func build_tilemap() -> void:
	Log.peer(self, "Replicating map...")
	var tmap: TileMap = target.map
	rpc_build_tilemap.rpc(tmap.global_position, tmap.global_rotation, tmap.global_scale)

## Create the [field map] on clients.
@rpc("authority", "call_remote", "reliable")
func rpc_build_tilemap(tposition: Vector2, trotation: float, tscale: Vector2):
	Log.peer(self, "Building map...")
	map = tilemap_scene.instantiate()
	map.global_position = tposition
	map.global_rotation = trotation
	map.global_scale = tscale
	add_child(map)

## Replicate the cells of [field target]'s [field map] to the remote [field map].
##
## The [field map] must be already created on clients.
## 
## Only takes layer 0 into consideration.
func build_tilemap_cells() -> void:
	Log.peer(self, "Replicating map cells...")
	var tmap: TileMap = target.map
	const layer = 0
	for coords in tmap.get_used_cells(layer):
		var source_id: int = tmap.get_cell_source_id(0, coords)
		var atlas_coords: Vector2i = tmap.get_cell_atlas_coords(0, coords)
		var alternative_tile: int = tmap.get_cell_alternative_tile(0, coords)
		rpc_build_tilemap_cell.rpc(layer, coords, source_id, atlas_coords, alternative_tile)
		
## Create a cell of [field map] on clients.
@rpc("authority", "call_remote", "reliable")
func rpc_build_tilemap_cell(
	layer: int, 
	coords: Vector2i, 
	source_id: int, 
	atlas_coords: Vector2i = Vector2i(-1, -1), 
	alternative_tile: int = 0
):
	Log.peer(self, "Building map cell: %s" % coords)
	map.set_cell(layer, coords, source_id, atlas_coords, alternative_tile)


## Replicate the [field tee] of the [field target] to the remote [field tee].
func build_tee() -> void:
	Log.peer(self, "Replicating tee...")
	var ttee: GolfTee = target.tee
	rpc_build_tee.rpc(ttee.global_position)
	rpc_build_tee_balls.rpc()

## Create the [GolfTee] object on clients.
@rpc("authority", "call_remote", "reliable")
func rpc_build_tee(tposition: Vector2):
	Log.peer(self, "Building tee...")
	tee = tee_scene.instantiate()
	tee.global_position = tposition
	add_child(tee)

## Create and initialize the [GolfBall] object on clients, at the [GolfTee]'s position.
@rpc("authority", "call_remote", "reliable")
func rpc_build_tee_balls():
	Log.peer(self, "Building tee balls...")
	for playernode in player_dir.get_children():
		var ball: GolfBall = tee.create(playernode)
		add_child(ball)

## Create and initialize a [GolfBall] for a single [PlayerNode] with the given name.
@rpc("authority", "call_remote", "reliable")
func rpc_build_tee_ball(player_name: String):
	Log.peer(self, "Building tee ball for: %s" % player_name)
	var playernode: PlayerNode = player_dir.get_playernode(player_name)
	var ball: GolfBall = tee.create(playernode)
	add_child(ball)


## Replicate the [field hole] of the [field target] to the remote [field hole].
func build_hole() -> void:
	Log.peer(self, "Replicating hole...")
	var thole: GolfHole = target.hole
	rpc_build_hole.rpc(thole.global_position, thole.global_scale)
	
## Create the [GolfHole] object on clients.
@rpc("authority", "call_remote", "reliable")
func rpc_build_hole(tposition: Vector2, tscale: Vector2):
	Log.peer(self, "Building hole...")
	hole = hole_scene.instantiate()
	hole.global_position = tposition
	hole.global_scale = tscale
	add_child(hole)


## Replicate the [field camera] of the [field target] to the remote [field camera].
func build_camera() -> void:
	Log.peer(self, "Replicating camera...")
	var tcamera: FollowCamera = target.camera
	rpc_build_camera.rpc(tcamera.global_position, target.camera_follows_player)

## Create the [Camera2D] object on clients.
@rpc("authority", "call_remote", "reliable")
func rpc_build_camera(tposition: Vector2, tfocus: bool):
	Log.peer(self, "Building camera...")
	camera = camera_scene.instantiate()
	camera.global_position = tposition
	if tfocus:
		camera.target = null  # TODO: Find local player
	add_child(camera)


func _on_playernode_created(node: Node):
	Log.peer(self, "Spawning new player...")
	var playernode: PlayerNode = node as PlayerNode
	rpc_build_tee_ball.rpc(playernode.player_name)
