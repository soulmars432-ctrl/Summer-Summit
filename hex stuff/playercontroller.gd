extends Node2D
class_name Playercontroller
@export var tilemap: TileMapLayer
@export var highlightgreen: TileMap
@export var highlightred: TileMap
var cell: Vector2i
var cell_variant_cache: Dictionary = {}
const highlightcoords = Vector2i(0, 0)
const unsafe = 0
const slainsafe = 2
const slainunsafe = 2
const tilecoord = Vector2i(0, 0)

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)
	EnemyManager.tilemap = tilemap
	EnemyManager.player = self
	EnemyManager.enemy_parent = get_tree().current_scene
	TurnManager.start_player_turn()

func _on_turn_started(state) -> void:
	if state == TurnManager.State.Playerturn:
		cell_variant_cache.clear()
		_highlight_valid_moves()
		EnemyManager.clear_killed_cells()

func _pick_source_cached(cell: Vector2i, sources: Array) -> int:
	if not cell_variant_cache.has(cell):
		cell_variant_cache[cell] = sources[randi_range(0, sources.size() - 1)]
	return cell_variant_cache[cell]

func _pick_source(sources: Array) -> int:
	return sources[randi_range(0, sources.size() - 1)]

func _highlight_valid_moves() -> void:
	_clear_highlights()
	var neighbors = tilemap.get_surrounding_cells(cell)
	for n in neighbors:
		if not tilemap.get_used_cells().has(n):
			continue
		var enemy = EnemyManager.get_enemy_at(n)
		if not enemy:
			if n in EnemyManager.killed_cells:
				highlightgreen.set_cell(0, n, slainsafe, tilecoord)
			else:
				highlightgreen.set_cell(0, n, 1, tilecoord)

	for enemy_cell in EnemyManager.enemies.keys():
		if tilemap.get_used_cells().has(enemy_cell):
			highlightred.set_cell(0, enemy_cell, unsafe, tilecoord)
		var enemy_node = EnemyManager.get_enemy_at(enemy_cell)
		var danger_cells = []
		if enemy_node.is_dragon:
			danger_cells = EnemyManager.get_dragon_moves(enemy_cell, tilemap)
		elif enemy_node.is_orc:
			danger_cells = EnemyManager.get_orc_moves(enemy_cell, tilemap)
		else:
			danger_cells = tilemap.get_surrounding_cells(enemy_cell)
		for danger_cell in danger_cells:
			if not tilemap.get_used_cells().has(danger_cell):
				continue
			if not EnemyManager.enemies.has(danger_cell):
				if danger_cell in EnemyManager.killed_cells:
					highlightred.set_cell(0, danger_cell, slainunsafe, tilecoord)
				else:
					highlightred.set_cell(0, danger_cell, unsafe, tilecoord)
	EnemyManager.clear_killed_cells() 

func _clear_highlights() -> void:
	for n in highlightgreen.get_used_cells(0):
		highlightgreen.erase_cell(0, n)
	for n in highlightred.get_used_cells(0):
		highlightred.erase_cell(0, n)

func _unhandled_input(event: InputEvent) -> void:
	if TurnManager.state != TurnManager.State.Playerturn:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_cell = tilemap.local_to_map(tilemap.to_local(get_global_mouse_position()))
		_try_resolve_click(clicked_cell)

func _try_resolve_click(target: Vector2i) -> void:
	var neighbors = tilemap.get_surrounding_cells(cell)
	if not neighbors.has(target):
		return
	if not tilemap.get_used_cells().has(target):
		return
	var enemy = EnemyManager.get_enemy_at(target)
	if enemy:
		_attack(enemy)
	else:
		_move_to(target)
	TurnManager.spend_action()
	if TurnManager.actions_remaining > 0:
		_highlight_valid_moves()
	else:
		_clear_highlights()

func _move_to(target: Vector2i) -> void:
	cell = target
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", tilemap.map_to_local(target), 0.5)
	Audio.play(16,19)

func _attack(enemy) -> void:
	EnemyManager.kill(enemy)
	Audio.play(4,7)
