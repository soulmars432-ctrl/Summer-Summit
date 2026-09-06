extends Label

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	text = "%d" % GameManager.score

func _on_score_changed(new_score: int) -> void:
	text = "%d" % new_score

	var base_color = _get_base_color(new_score)
	var base_scale = _get_base_scale(new_score)

	modulate = Color(1, 0.2, 0.2)
	var color_tween = create_tween()
	color_tween.tween_property(self, "modulate", base_color, 0.3)

	scale = base_scale * 1.3
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", base_scale, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _get_base_color(score: int) -> Color:
	if score >= 10:
		return Color(1, 0.9, 0.2)
	return Color(1, 1, 1)

func _get_base_scale(score: int) -> Vector2:
	var tier = score / 10
	var size_multiplier = 1.0 + (tier * 0.15)
	return Vector2(size_multiplier, size_multiplier)
