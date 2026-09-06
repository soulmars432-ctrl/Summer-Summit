extends Node2D

@export var tilemap: TileMapLayer

func _ready() -> void:
	await get_tree().process_frame
	var first_wave_cells = [Vector2i(-3, -2), Vector2i(-3, 1), Vector2i(3, -2), Vector2i(3, 1)]
	for cell in first_wave_cells:
		var enemy = preload("res://hex stuff/enemy.tscn").instantiate()
		add_child(enemy)
		enemy.place_at(cell, tilemap)
		enemy.just_spawned = false
		EnemyManager.register_enemy(enemy, cell)
	Audio.play_ambient(0)
	Audio.play_music()
