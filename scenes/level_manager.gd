extends Node
class_name LevelManager

## The levels that should be loaded by the server and sent to the clients.
const levels: Array[PackedScene] = [
	preload("res://scenes/golf_level_1.tscn"),
	preload("res://scenes/golf_level_2.tscn"),
]

## The index of the current level in [field levels].
var level_idx: int = -1

## Class containing the components of a level.
class Components:
	## All levels must include a [TileMap] named "TileMap".
	var tilemap: TileMap = null

	## The [PackedScene] to initialize on clients as [TileMap].
	const tilemap_scene: PackedScene = preload("res://scenes/golf_tilemap.tscn")
	
	## All levels must include a [GolfTee] named "GolfTee".
	##
	## It will be used to spawn the player
	var tee: GolfTee = null

	## The [PackedScene] to initialize on clients as [GolfTee].
	const tee_scene: PackedScene = preload("res://scenes/golf_tee.tscn")

	## All levels must include a [GolfHole] named "GolfHole".
	var hole: GolfHole = null

	## The [PackedScene] to initialize on clients as [GolfHole].
	const hole_scene = preload("res://scenes/golf_hole.tscn")

	## Create a new [Components] instance from a [PackedScene].
	static func from_scene(scene: PackedScene) -> Components:
		var obj = new()
		obj.tilemap = scene.get_node("TileMap")
		obj.tee = scene.get_node("GolfTee")
		obj.hole = scene.get_node("GolfHole")
		return obj
	
	## Create the [TileMap] object on clients.
	@rpc("authority", "call_remote", "reliable")
	func rpc_build_tilemap(parent: Node):
		var obj = tilemap_scene.instantiate()
		parent.add_child(obj)
	
	## Create the [GolfTee] object on clients.
	@rpc("authority", "call_remote", "reliable")
	func rpc_build_tee(parent: Node, position: Vector2):
		var obj = tee_scene.instantiate()
		obj.position = position
		parent.add_child(obj)
	
	## Create the [GolfHole] object on clients.
	@rpc("authority", "call_remote", "reliable")
	func rpc_build_hole(parent: Node, position: Vector2, scale: Vector2):
		var obj = hole_scene.instantiate()
		obj.position = position
		obj.scale = scale
		parent.add_child(obj)

	## TODO: Place tiles



func get_current_level() -> PackedScene:
	return levels[level_idx]


func load_level_components() -> Components:
	return Components.from_scene(get_current_level())

