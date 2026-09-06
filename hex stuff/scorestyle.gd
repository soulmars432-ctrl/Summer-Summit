extends Node

func get_base_color(score: int) -> Color:
	if score >= 10:
		return Color(1, 0.9, 0.2)
	return Color(1, 1, 1)

func get_base_scale(score: int) -> Vector2:
	var tier = score / 10
	var size_multiplier = min(1.0 + (tier * 0.15), 2.0)
	return Vector2(size_multiplier, size_multiplier)
