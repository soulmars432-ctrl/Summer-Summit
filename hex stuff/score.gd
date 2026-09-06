extends Label

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	text = "%d" % GameManager.score

func _on_score_changed(new_score: int) -> void:
	text = "%d" % new_score
	modulate = Color(1, 0.9, 0.2)
	var tween = create_tween()
	scale = Vector2(1.3, 1.3)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
