extends Node

var enemies: Dictionary = {}
var tilemap: TileMap
var player: Playercontroller
var enemy_scene: PackedScene = preload("res://hex stuff/enemy.tscn")
var pending_spawn_cells: Array = []
signal wave_incoming(spawn_cells)
signal wave_started

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)
	print(Engine.get_version_info())
	


func _on_turn_started(state) -> void:
	if state == TurnManager.State.Enemyturn:
		step_enemies_toward_player(player.cell, tilemap)

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
	
func step_dragon_toward_player(player_cell: Vector2i, tilemap: TileMap) -> void:
	var old_positions = enemies.duplicate()
	enemies.clear()

	for cell in old_positions.keys():
		var enemy = old_positions[cell]
		var next_cell = _get_dragon_step_toward(cell, player_cell, tilemap)

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
		if not tilemap.get_used_cells(0).has(n):
			continue
		var d = _hex_distance(n, to)
		if d < best_dist:
			best_dist = d
			best = n
	return best
func _get_dragon_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMap) -> Vector2i:
	var test = tilemap.get_neighbor_cell(Vector2i(3,3), TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
	print("from ", Vector2i(3,3), " -> ", test)
	var neighbors = get_dragon_moves(from, tilemap)
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

func spawn_pending_wave(tilemap: TileMap, parent: Node) -> void:
	for cell in pending_spawn_cells:
		var enemy = enemy_scene.instantiate()
		parent.add_child(enemy)
		enemy.place_at(cell, tilemap)
		register_enemy(enemy, cell)
	pending_spawn_cells.clear()
	wave_started.emit()

func get_dragon_moves(pos: Vector2i, tilemap: TileMap) -> Array:
	var res = []
	var directions = [
		Vector2i(1, 0),   # E
	Vector2i(1, -1),  # NE
	Vector2i(0, -1),  # N
	Vector2i(-1, 0),  # W
	Vector2i(-1, 1),  # SW
	Vector2i(0, 1),   # S
	]
	for d in directions:
		res.append_array(generate(pos, d, tilemap, []))
	return res

func generate(cell: Vector2i, dir: Vector2i, tilemap: TileMap, res: Array) -> Array:
	var new_cell = cell + dir
	if tilemap.get_cell_source_id(0, new_cell) == -1:
		return res
	res.append(new_cell)
	generate(new_cell, dir, tilemap, res)
	return res
