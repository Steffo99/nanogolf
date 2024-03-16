extends Label
class_name PlayerScoreLabel


func from_score(strokes: int, playernode: PlayerNode) -> void:
	text = "%s - %d" % [playernode.player_name, strokes]
	modulate = playernode.player_color
	modulate.a = 0.3 if playernode.get_multiplayer_authority() == 1 else 1.0
