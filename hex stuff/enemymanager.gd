extends Node

var enemies: Dictionary = {}
var tilemap: TileMap
var enemy_parent: Node
var player: Playercontroller
var goblin_scene: PackedScene = preload("res://hex stuff/enemy.tscn")
var dragon_scene: PackedScene = preload("res://hex stuff/dragon.tscn")
var pending_spawn_cells: Array = []
var wave_announced_this_turn: bool = false
var wave_cleared_pending: bool = false
signal wave_incoming(spawn_cells)
signal wave_started

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)

func _on_turn_started(state) -> void:
	if state == TurnManager.State.Enemyturn:
		step_all_enemies_toward_player(player.cell, tilemap)

func step_all_enemies_toward_player(player_cell: Vector2i, tilemap: TileMap) -> void:
	var old_positions = enemies.duplicate()
	enemies.clear()

	for cell in old_positions.keys():
		var enemy = old_positions[cell]

		if enemy.just_spawned:
			enemy.just_spawned = false
			enemies[cell] = enemy
			continue

		var next_cell: Vector2i
		if enemy.is_dragon:
			next_cell = _get_dragon_step_toward(cell, player_cell, tilemap)
		else:
			next_cell = _get_step_toward(cell, player_cell, tilemap)

		if next_cell == player_cell:
			GameManager.player_died()
			enemies[cell] = enemy
			continue

		enemy.position = tilemap.map_to_local(next_cell)
		enemies[next_cell] = enemy

	TurnManager.end_enemy_turn()

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
	if enemies.is_empty():
		wave_cleared_pending = true

func _on_wave_cleared() -> void:
	var valid_cells = tilemap.get_used_cells(0)
	announce_next_wave(4, valid_cells)
	wave_announced_this_turn = true

func _find_cell_for(enemy: Node2D):
	for c in enemies.keys():
		if enemies[c] == enemy:
			return c
	return null

func _get_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMap) -> Vector2i:
	var neighbors = tilemap.get_surrounding_cells(from)
	var best = from
	var best_dist = _hex_distance(from, to)
	for n in neighbors:
		if enemies.has(n):
			continue
		if not tilemap.get_used_cells(0).has(n):
			continue
		var d = _hex_distance(n, to)
		if d < best_dist:
			best_dist = d
			best = n
	return best

func has_pending_wave() -> bool:
	return not pending_spawn_cells.is_empty()

func _get_dragon_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMap) -> Vector2i:
	var reachable = get_line_cells(from, tilemap)
	var best = from
	var best_dist = _hex_distance(from, to)
	for n in reachable:
		if enemies.has(n):
			continue
		var d = _hex_distance(n, to)
		if d < best_dist:
			best_dist = d
			best = n
	var from_axial = offset_to_axial(from)
	var best_axial = offset_to_axial(best)
	var diff = best_axial - from_axial
	if diff != Vector2i.ZERO:
		var step_dir = Vector2i(sign(diff.x), sign(diff.y))
		var one_step_axial = from_axial + step_dir
		return axial_to_offset(one_step_axial)
	return from

func offset_to_axial(cell: Vector2i) -> Vector2i:
	var q = cell.x
	var r = cell.y - (cell.x - (cell.x & 1)) / 2
	return Vector2i(q, r)
	
func axial_to_offset(axial: Vector2i) -> Vector2i:
	var col = axial.x
	var row = axial.y + (axial.x - (axial.x & 1)) / 2
	return Vector2i(col, row)
	
const hexdir = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

func get_line_cells(from_offset: Vector2i, tilemap: TileMap, max_range: int = 10) -> Array:
	var line_cells = []
	var from_axial = offset_to_axial(from_offset)
	for dir in hexdir:
		for step in range(1, max_range + 1):
			var axial_step = from_axial + dir * step
			var offset_step = axial_to_offset(axial_step)
			if not tilemap.get_used_cells(0).has(offset_step):
				break
			line_cells.append(offset_step)
	return line_cells

func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var axial_a = offset_to_axial(a)
	var axial_b = offset_to_axial(b)
	var dq = axial_b.x - axial_a.x
	var dr = axial_b.y - axial_a.y
	return (abs(dq) + abs(dr) + abs(dq + dr)) / 2

func announce_next_wave(count: int, valid_cells: Array, exclude: Array = []) -> void:
	pending_spawn_cells.clear()
	var candidates = valid_cells.duplicate()
	candidates.shuffle()
	for c in candidates:
		if pending_spawn_cells.size() >= count:
			break
		if c in exclude:
			continue
		pending_spawn_cells.append(c)
	wave_incoming.emit(pending_spawn_cells)

func spawn_pending_wave() -> void:
	for cell in pending_spawn_cells:
		var scene = dragon_scene if randf() < 0.3 else goblin_scene
		var enemy = scene.instantiate()
		enemy_parent.add_child(enemy)
		enemy.place_at(cell, tilemap)
		register_enemy(enemy, cell)

		if cell == player.cell:
			GameManager.player_died()
	pending_spawn_cells.clear()
	wave_started.emit()
		
func try_announce_wave_if_cleared() -> void:
	if wave_cleared_pending:
		var valid_cells = tilemap.get_used_cells(0)
		announce_next_wave(4, valid_cells)
		wave_cleared_pending = false
		wave_announced_this_turn = true
