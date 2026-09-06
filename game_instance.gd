extends Node

const _BACKGROUND := preload("res://background.gd")

func _ready() -> void:
	add_child(_BACKGROUND.new())
