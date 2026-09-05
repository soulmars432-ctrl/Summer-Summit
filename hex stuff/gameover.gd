extends Control

@onready var score_label: Label = $Label
@onready var restart_button: Button = $Restart

func _ready() -> void:
	visible = false
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)

func _on_game_over(final_score: int) -> void:
	score_label.text = "Game Over!\nScore: %d" % final_score
	visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameManager.score = 0
	GameManager.is_game_over = false
	_clear_all_highlights_on_restart()
	get_tree().reload_current_scene()

func _clear_all_highlights_on_restart() -> void:
	var green = get_node("../Highlightgreen")
	var red = get_node("../Highlightred")
	for n in green.get_used_cells(0):
		green.erase_cell(0, n)
	for n in red.get_used_cells(0):
		red.erase_cell(0, n)
