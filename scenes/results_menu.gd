extends Control
class_name ResultsMenu


@export_category("References")

@export var results_grid: GridContainer

const label_scene: PackedScene = preload("res://scenes/player_label.tscn")


var player_dir: PlayerNodeDirectory = null



func _ready():
	var max_hole_scores = 0

	for playernode in player_dir.get_children():
		var player: PlayerLabel = label_scene.instantiate()
		player.set_player_name(playernode.player_name)
		player.set_player_color(playernode.player_color)
		player.set_possessed(playernode.get_multiplayer_authority())
		results_grid.add_child(player)

		max_hole_scores = max(max_hole_scores, len(playernode.hole_scores))
		var total_score = 0
		for hole_score in playernode.hole_scores:
			var score: PlayerLabel = label_scene.instantiate()
			if hole_score != -1:
				score.text = "%d" % hole_score
			else:
				score.text = "-"
			score.set_player_color(playernode.player_color)
			score.set_possessed(playernode.get_multiplayer_authority())
			score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			score.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			results_grid.add_child(score)
			if hole_score == -1 or total_score == -1:
				total_score = -1
			else:
				total_score += hole_score
	
		var total: PlayerLabel = label_scene.instantiate()
		if total_score != -1:
			total.text = "[%d]" % total_score
		else:
			total.text = "-"
		total.set_player_color(playernode.player_color)
		total.set_possessed(playernode.get_multiplayer_authority())
		total.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		total.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		results_grid.add_child(total)

	results_grid.columns = max_hole_scores + 2


signal leave_confirmed

func _on_leave_button_pressed() -> void:
	leave_confirmed.emit()
