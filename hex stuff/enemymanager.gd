extends Node

var enemies: Dictionary = {}
var tilemap: TileMapLayer

var enemy_parent: Node
var player: Playercontroller
var goblin_scene: PackedScene = preload("res://hex stuff/enemy.tscn")
var dragon_scene: PackedScene = preload("res://hex stuff/dragon.tscn")
var orc_scene: PackedScene = preload("res://hex stuff/orc.tscn")
var pending_spawn_cells: Array = []
var all_enemy_spawn:Array = []
var wave_announced_this_turn: bool = false
var wave_cleared_pending: bool = false
var wave_num:int = 1
var killed_cells: Array = []
signal wave_incoming(spawn_cells)
signal wave_started

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)

func _on_turn_started(state) -> void:
	if state == TurnManager.State.Enemyturn:
		step_all_enemies_toward_player(player.cell, tilemap)

func clear_killed_cells() -> void:
	killed_cells.clear()

func step_all_enemies_toward_player(player_cell: Vector2i, tilemap: TileMapLayer) -> void:
	var old_positions = enemies.duplicate()
	enemies.clear()
	var claimed_cells = {}
	for c in old_positions.keys():
		claimed_cells[c] = true

	for cell in old_positions.keys():
		var enemy = old_positions[cell]
		if not enemy:
			continue
		if enemy.just_spawned:
			enemy.just_spawned = false
			enemies[cell] = enemy
			continue

		claimed_cells.erase(cell)

		var next_cell: Vector2i
		if enemy.is_dragon:
			next_cell = _get_dragon_step_toward(cell, player_cell, tilemap, claimed_cells)
		elif enemy.is_orc:
			next_cell = _get_orc_step_toward(cell, player_cell, tilemap, claimed_cells)
		else:
			next_cell = _get_step_toward(cell, player_cell, tilemap, claimed_cells)

		if next_cell == player_cell:
			GameManager.player_died()
			enemies[cell] = enemy
			claimed_cells[cell] = true
			continue

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(enemy, "position", tilemap.map_to_local(next_cell), 0.6)
		enemies[next_cell] = enemy
		claimed_cells[next_cell] = true

	TurnManager.end_enemy_turn()

func register_enemy(enemy: Node2D, cell: Vector2i) -> void:
	enemies[cell] = enemy

func get_enemy_at(cell: Vector2i):
	return enemies.get(cell, null)

func kill(enemy: Node2D) -> void:
	var cells = _find_cell_for(enemy)
	for cell in cells:
		enemies.erase(cell)
		killed_cells.append(cell)

	var points = 1
	if enemy.is_orc:
		points = 3
	elif enemy.is_dragon:
		points = 5

	enemy.queue_free()
	GameManager.add_score(points)

	if enemies.is_empty():
		wave_cleared_pending = true

func _find_cell_for(enemy: Node2D):
	var all_enemy = []
	for c in enemies.keys():
		if enemies[c] == enemy:
			all_enemy.append(c)
	return all_enemy

func _get_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMapLayer, claimed_cells: Dictionary) -> Vector2i:
	var neighbors = tilemap.get_surrounding_cells(from)
	var best = from
	var best_dist = _hex_distance(from, to)
	for n in neighbors:
		if enemies.has(n) or claimed_cells.has(n):
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

func _get_dragon_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMapLayer, claimed_cells: Dictionary) -> Vector2i:
	var reachable = get_dragon_moves(from, tilemap)
	var best = from
	var best_dist = _hex_distance(from, to)
	for n in reachable:
		if enemies.has(n) or claimed_cells.has(n):
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

func _hex_distance(a: Vector2i, b: Vector2i) -> int:
	var axial_a = offset_to_axial(a)
	var axial_b = offset_to_axial(b)
	var dq = axial_b.x - axial_a.x
	var dr = axial_b.y - axial_a.y
	return (abs(dq) + abs(dr) + abs(dq + dr)) / 2

func announce_next_wave(count: int, valid_cells: Array, exclude: Array = []) -> void:
	wave_num += 1
	pending_spawn_cells.clear()
	var candidates = valid_cells.duplicate()
	candidates.shuffle()
	for c in candidates:
		if pending_spawn_cells.size() >= count:
			break
		if c in exclude:
			continue
		pending_spawn_cells.append(c)
	for cell in pending_spawn_cells:
		var rand = randf()
		var scene = "goblin"
		if rand < 0.5:
			scene = "goblin"
		elif rand < 0.8:
			scene = "orc"
		else:
			scene = "dragon"
		all_enemy_spawn.append(scene)
	
	wave_incoming.emit(pending_spawn_cells, all_enemy_spawn)

func spawn_pending_wave() -> void:
	for i in range(pending_spawn_cells.size()):
		var scene = goblin_scene
		if all_enemy_spawn[i] == "goblin":
			scene = goblin_scene
		elif all_enemy_spawn[i] == "orc":
			scene = orc_scene
		else:
			scene = dragon_scene
		var enemy = scene.instantiate()
		enemy_parent.add_child(enemy)
		enemy.place_at(pending_spawn_cells[i], tilemap)
		register_enemy(enemy, pending_spawn_cells[i])

		if pending_spawn_cells[i] == player.cell:
			GameManager.player_died()

	pending_spawn_cells.clear()
	wave_started.emit()
	Audio.play(11,14)

func try_announce_wave_if_cleared() -> void:
	if wave_cleared_pending:
		var valid_cells = tilemap.get_used_cells()
		var progress_bias: float = wave_num / (wave_num + 5.0)
		# 2. Roll between your rising minimum bias and 1.0
		var random_decimal: float = randf_range(progress_bias, 1.0)
		# 3. Lerp across your target range (4.0 to 7.0)
		var enemies: float = lerp(4.0, 7.0, random_decimal)
		announce_next_wave(enemies, valid_cells)
		wave_cleared_pending = false
		wave_announced_this_turn = true

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
		

func _get_orc_step_toward(from: Vector2i, to: Vector2i, tilemap: TileMapLayer, claimed_cells: Dictionary) -> Vector2i:
	var reachable = get_orc_moves(from, tilemap)
	var best = from
	var best_dist = _hex_distance(from, to)
	for n in reachable:
		if enemies.has(n) or claimed_cells.has(n):
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
		
