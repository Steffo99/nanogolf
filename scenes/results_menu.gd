extends Control
class_name ResultsMenu


@export_category("References")

@export var results_grid: GridContainer

const player_label_scene: PackedScene = preload("res://scenes/player_label.tscn")
const score_label_scene: PackedScene = preload("res://scenes/score_label.tscn")


var player_dir: PlayerNodeDirectory = null



func _ready():
	var max_hole_scores = 0

	for playernode in player_dir.get_children():
		var player: PlayerLabel = player_label_scene.instantiate()
		player.set_player_name(playernode.player_name)
		player.set_player_color(playernode.player_color)
		player.set_possessed(playernode.get_multiplayer_authority())
		results_grid.add_child(player)

		max_hole_scores = max(max_hole_scores, len(playernode.hole_scores))
		var total_score = 0
		for hole_score in playernode.hole_scores:
			var score: ScoreLabel = score_label_scene.instantiate()
			score.set_partial(hole_score)
			score.set_player_color(playernode.player_color)
			score.set_possessed(playernode.get_multiplayer_authority())
			results_grid.add_child(score)
			if hole_score == -1 or total_score == -1:
				total_score = -1
			else:
				total_score += hole_score
	
		var total: ScoreLabel = score_label_scene.instantiate()
		total.set_total(total_score)
		total.set_player_color(playernode.player_color)
		total.set_possessed(playernode.get_multiplayer_authority())
		results_grid.add_child(total)

	results_grid.columns = max_hole_scores + 2


signal leave_confirmed

func _on_leave_button_pressed() -> void:
	leave_confirmed.emit()
