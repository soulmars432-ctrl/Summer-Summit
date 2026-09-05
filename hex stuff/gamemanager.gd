extends Node

signal score_changed(new_score)
signal game_over(final_score)

var score: int = 0
var is_game_over: bool = false

func add_score(amount: int = 1) -> void:
	if is_game_over:
		return
	score += amount
	score_changed.emit(score)

func player_died() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_over.emit(score)
	# freeze input, game over
