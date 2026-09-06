extends Node

var enemies: Dictionary = {}
var tilemap: TileMapLayer

var enemy_parent: Node
var player: Playercontroller
var goblin_scene: PackedScene = preload("res://hex stuff/enemy.tscn")
var dragon_scene: PackedScene = preload("res://hex stuff/dragon.tscn")
var orc_scene: PackedScene = preload("res://hex stuff/orc.tscn")
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

func step_all_enemies_toward_player(player_cell: Vector2i, tilemap: TileMapLayer) -> void:
	var old_positions = enemies.duplicate()
	enemies.clear()

	for cell in old_positions.keys():
		var enemy = old_positions[cell]
		if not enemy:
			continue
		if enemy.just_spawned:
			enemy.just_spawned = false
			enemies[cell] = enemy
			continue

		var next_cell: Vector2i
		if enemy.is_dragon:
			next_cell = _get_dragon_step_toward(cell, player_cell, tilemap)
		elif enemy.is_orc:
			next_cell = _get_orc_step_toward(cell, player_cell, tilemap)
		else:
			next_cell = _get_step_toward(cell, player_cell, tilemap)

		if next_cell == player_cell:
			GameManager.player_died()
			enemies[cell] = enemy
			continue
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy,"position", tilemap.map_to_local(next_cell),0.6)
		enemies[next_cell] = enemy

	TurnManager.end_enemy_turn()

func register_enemy(enemy: Node2D, cell: Vector2i) -> void:
	enemies[cell] = enemy

func get_enemy_at(cell: Vector2i):
	return enemies.get(cell, null)

func kill(enemy: Node2D) -> void:
	for cell in _find_cell_for(enemy):
		if cell != null:
			enemies.erase(cell)
		enemy.queue_free()
		GameManager.add_score()
		if enemies.is_empty():
			wave_cleared_pending = true

func _find_cell_for(enemy: Node2D):
	var all_enemy = []
	for c in enemies.keys():
		if enemies[c] == enemy:
			all_enemy.append(c)
	return all_enemy

func _get_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMapLayer) -> Vector2i:
	var neighbors = tilemap.get_surrounding_cells(from)
	var best = from
	var best_dist = _hex_distance(from, to)
	for n in neighbors:
		if enemies.has(n):
			continue
		if not tilemap.get_used_cells().has(n):
			continue
		var d = _hex_distance(n, to)
		if d < best_dist:
			best_dist = d
			best = n
	return best
	
func has_pending_wave() -> bool:
	return not pending_spawn_cells.is_empty()

func _get_dragon_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMapLayer) -> Vector2i:
	var reachable = get_dragon_moves(from, tilemap)
	var best = from
	var best_dist = _hex_distance(from, to)
	for n in reachable:
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
		var rand = randf()
		var scene = goblin_scene
		if rand < 0.7 and rand > 0.4:
			scene = dragon_scene
		elif rand <= 0.4:
			scene = orc_scene
		else:
			scene = goblin_scene
		var enemy = scene.instantiate()
		enemy_parent.add_child(enemy)
		enemy.place_at(cell, tilemap)
		register_enemy(enemy, cell)

		if cell == player.cell:
			GameManager.player_died()

	pending_spawn_cells.clear()
	wave_started.emit()
	Audio.play(2)

func try_announce_wave_if_cleared() -> void:
	if wave_cleared_pending:
		var valid_cells = tilemap.get_used_cells()
		announce_next_wave(4, valid_cells)
		wave_cleared_pending = false
		wave_announced_this_turn = true

func step_orc_toward_player(player_cell: Vector2i, map: TileMapLayer) -> void:
	var old_positions = enemies.duplicate()
	enemies.clear()

	for cell in old_positions.keys():
		var enemy = old_positions[cell]
		var next_cell = _get_orc_step_toward(cell, player_cell, map)

		if next_cell == player_cell:
			GameManager.player_died()
			enemies[cell] = enemy
			continue
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy,"position", tilemap.map_to_local(next_cell),0.6)
		enemies[next_cell] = enemy

	TurnManager.end_enemy_turn()


func get_dragon_moves(pos: Vector2i, tilemap: TileMapLayer) -> Array:
	var possible = []
	var directions = [
		TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_SIDE,
		TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_SIDE,
		TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE,
		TileSet.CELL_NEIGHBOR_TOP_RIGHT_SIDE,
		TileSet.CELL_NEIGHBOR_TOP_SIDE,
		TileSet.CELL_NEIGHBOR_BOTTOM_SIDE
	]
	for d in directions:
		possible.append_array(generate(pos, d, tilemap, []))
	return possible

func generate(cell: Vector2i, dir: int, tilemap: TileMapLayer, res: Array) -> Array:
	if tilemap.get_cell_source_id(tilemap.get_neighbor_cell(cell, dir)) != -1:
		var new_cell = tilemap.get_neighbor_cell(cell, dir)
		res.append(new_cell)
		generate(new_cell, dir, tilemap, res)
	return res
		

func _get_orc_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMapLayer) -> Vector2i:
	var reachable = get_orc_moves(from, tilemap)
	var best = from
	var best_dist = _hex_distance(from, to)
	for n in reachable:
		if enemies.has(n):
			continue
		var d = _hex_distance(n, to)
		if d < best_dist:
			best_dist = d
			best = n
	return best

func get_orc_moves(pos: Vector2i, tilemap: TileMapLayer) -> Array:
	var possible = []
	var directions = [
		Vector2i.RIGHT,
		Vector2i.LEFT, 
		Vector2i.UP,   
		Vector2i.DOWN,  
	]
	for d in directions:
		possible.append_array(generate_orc(pos, d, tilemap, []))
	return possible

func generate_orc(cell: Vector2i, dir: Vector2i, tilemap: TileMapLayer, res: Array) -> Array:
	if tilemap.get_cell_source_id(cell + dir) != -1:
		var new_cell = cell + dir
		res.append(new_cell)
		generate_orc(new_cell, dir, tilemap, res)
	return res
		
