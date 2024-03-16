extends Control
class_name GameHUD


@export var strokes_label: Label

@export var scores_panel: PanelContainer

@export var scores_container: Control


const score_scene = preload("res://scenes/player_score_label.tscn")


func _on_level_completed(_level: GolfLevel) -> void:
	strokes_label.text = "0"
	for child in scores_container.get_children():
		child.queue_free()
	scores_panel.hide()

func _on_playernode_name_changed(old: String, new: String, playernode: PlayerNode) -> void:
	var instance = get_node_or_null("PlayerScoreLabel__%s" % old)
	if instance != null:
		instance.from_score(playernode)
		instance.name = "PlayerScoreLabel__%s" % new

func _on_playernode_color_changed(_old: Color, _new: Color, playernode: PlayerNode) -> void:
	var instance = get_node_or_null("PlayerScoreLabel__%s" % playernode.player_name)
	if instance != null:
		instance.from_score(playernode)

func _on_playernode_possessed(_old: int, _new: int, playernode: PlayerNode) -> void:
	var instance = get_node_or_null("PlayerScoreLabel__%s" % playernode.player_name)
	if instance != null:
		instance.from_score(playernode)

func _on_playernode_score_reported(strokes: int, playernode: PlayerNode) -> void:
	var score_instance = score_scene.instantiate()
	score_instance.from_score(strokes, playernode)
	score_instance.name = "PlayerScoreLabel__%s" % playernode.player_name
	scores_container.add_child(score_instance)
	scores_panel.show()

func _on_playernode_scores_changed(_old: Array, _new: Array, _playernode: PlayerNode) -> void:
	pass

func _on_local_player_spawned(ball: GolfBall, _level: GolfLevel) -> void:
	ball.putt_controller.putt.connect(_on_putt.bind(ball))

func _on_putt(_putt_vector: Vector2, ball: GolfBall) -> void:
	strokes_label.text = "%d" % ball.strokes


func _on_strokes_changed(strokes: int) -> void:
	strokes_label.text = "%s" % strokes
