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
	get_tree().reload_current_scene()
