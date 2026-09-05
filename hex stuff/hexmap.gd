extends Node2D

@export var tilemap: TileMap

func _ready() -> void:
	await get_tree().process_frame
	var test_enemy = preload("res://hex stuff/enemy.tscn").instantiate()
	add_child(test_enemy)
	var spawn_cell = Vector2i(2, 2)
	test_enemy.place_at(spawn_cell, tilemap)
	EnemyManager.register_enemy(test_enemy, spawn_cell)
