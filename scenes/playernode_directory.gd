extends Node
class_name PlayerNodeDirectory


## The scene to instantiate on creation of a new [PlayerNode].
@export var playernode_scene: PackedScene = preload("res://scenes/playernode.tscn")


## Find the subordinate [PlayerNode] with the given player_name, and return it if found, otherwise return null.
func get_playernode(player_name: String) -> PlayerNode:
	var sanitized_player_name = PlayerNode.sanitize_player_name(player_name)
	return get_node_or_null(sanitized_player_name)


## Create a new [PlayerNode] for the given [param player_name], giving control of it to [param peer_id].
##
## If a node with the given name already exists, only its multiplayer authority is changed, leaving the rest intact.
##
## If both node and multiplayer authority match the requested values, nothing is done at all.
@rpc("authority", "call_local", "reliable")
func rpc_possess_playernode(player_name: String, peer_id: int):
	var playernode: PlayerNode = get_playernode(player_name)
	# If the playernode does not exist, create it
	if playernode == null:
		playernode = playernode_scene.instantiate()
		playernode.name_changed.connect(_on_playernode_name_changed.bind(playernode))
		playernode.color_changed.connect(_on_playernode_color_changed.bind(playernode))
		playernode.possessed.connect(_on_playernode_possessed.bind(playernode))
		playernode.score_reported.connect(_on_playernode_score_reported.bind(playernode))
		playernode.scores_changed.connect(_on_playernode_scores_changed.bind(playernode))
		playernode.putt_performed.connect(_on_playernode_putt_performed.bind(playernode))
		var sanitized_player_name = PlayerNode.sanitize_player_name(player_name)
		playernode.player_name = sanitized_player_name
		playernode.name = sanitized_player_name
		add_child(playernode)
	# If the multiplayer authority does not match the requested one, make it match
	playernode.possess(peer_id)



func _on_playernode_name_changed(old: String, new: String, playernode: PlayerNode) -> void:
	playernode_name_changed.emit(old, new, playernode)

func _on_playernode_color_changed(old: Color, new: Color, playernode: PlayerNode) -> void:
	playernode_color_changed.emit(old, new, playernode)

func _on_playernode_possessed(old: int, new: int, playernode: PlayerNode) -> void:
	playernode_possessed.emit(old, new, playernode)
	if playernode.is_multiplayer_authority() and not multiplayer.is_server():
		local_playernode_possessed.emit(old, new, playernode)

func _on_playernode_score_reported(strokes: int, playernode: PlayerNode) -> void:
	playernode_score_reported.emit(strokes, playernode)

func _on_playernode_scores_changed(old: Array, new: Array, playernode: PlayerNode) -> void:
	playernode_scores_changed.emit(old, new, playernode)

func _on_playernode_putt_performed(ball: GolfBall, playernode: PlayerNode) -> void:
	playernode_putt_performed.emit(ball, playernode)


## Emitted when the name of one of the children [PlayerNode]s changes on the local scene.
signal playernode_name_changed(old: String, new: String, playernode: PlayerNode)

## Emitted when the color of one of the children [PlayerNode]s changes on the local scene.
signal playernode_color_changed(old: Color, new: Color, playernode: PlayerNode)

## Emitted everywhere when one of the children [PlayerNode]s has changed multiplayer authority.
signal playernode_possessed(old: int, new: int, playernode: PlayerNode)

## Emitted on a client when it becomes authority of a [PlayerNode].
signal local_playernode_possessed(old: int, new: int, playernode: PlayerNode)

## Emitted when a [PlayerNode] reports a score.
signal playernode_score_reported(strokes: int, playernode: PlayerNode)

## Emitted when the scores of one of the children [PlayerNode]s change on the local scene.
signal playernode_scores_changed(old: Array, new: Array, playernode: PlayerNode)

## Emitted when a [PlayerNode] performs a putt on its controlled [GolfBall].
signal playernode_putt_performed(ball: GolfBall, playernode: PlayerNode)
