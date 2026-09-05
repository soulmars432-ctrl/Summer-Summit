extends Node

var enemies: Dictionary = {}

func register_enemy(enemy: Node2D, cell: Vector2i) -> void:
	enemies[cell] = enemy

func get_enemy_at(cell: Vector2i):
	return enemies.get(cell, null)

func kill(enemy: Node2D) -> void:
	var cell = _find_cell_for(enemy)
	if cell != null:
		enemies.erase(cell)
	enemy.queue_free()
	GameManager.add_score()

func _find_cell_for(enemy: Node2D):
	for c in enemies.keys():
		if enemies[c] == enemy:
			return c
	return null

func step_enemies_toward_player(player_cell: Vector2i, tilemap: TileMap) -> void:
	var old_positions = enemies.duplicate()
	enemies.clear()

	for cell in old_positions.keys():
		var enemy = old_positions[cell]
		var next_cell = _get_step_toward(cell, player_cell, tilemap)

		if next_cell == player_cell:
			GameManager.player_died()
			enemies[cell] = enemy
			continue

		enemy.position = tilemap.map_to_local(next_cell)
		enemies[next_cell] = enemy

	TurnManager.end_enemy_turn()

func _get_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMap) -> Vector2i:
	var neighbors = tilemap.get_surrounding_cells(from)
	var best = from
	var best_dist = _hex_distance(from, to)

	for n in neighbors:
		if enemies.has(n):
			continue
		var d = _hex_distance(n, to)
		if d < best_dist:
			best_dist = d
			best = n
	return best

func offset_to_axial(cell: Vector2i) -> Vector2i:
	var q = cell.x
	var r = cell.y - (cell.x - (cell.x & 1)) / 2
	return Vector2i(q, r)

func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var axial_a = offset_to_axial(a)
	var axial_b = offset_to_axial(b)
	var dq = axial_b.x - axial_a.x
	var dr = axial_b.y - axial_a.y
	return (abs(dq) + abs(dr) + abs(dq + dr)) / 2
