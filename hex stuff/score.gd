extends Label

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	text = "%d" % GameManager.score

func _on_score_changed(new_score: int) -> void:
	text = "%d" % new_score
