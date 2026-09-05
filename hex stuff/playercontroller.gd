extends Node2D
class_name Playercontroller

@export var tilemap: TileMap
@export var highlightgreen: TileMap
@export var highlightred: TileMap
var cell: Vector2i
const highlightcoords = Vector2i(0, 0)

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)
	EnemyManager.tilemap = tilemap
	EnemyManager.player = self
	TurnManager.start_player_turn()

func _on_turn_started(state) -> void:
	if state == TurnManager.State.Playerturn:
		_highlight_valid_moves()

func _highlight_valid_moves() -> void:
	_clear_highlights()
	var neighbors = tilemap.get_surrounding_cells(cell)
	for n in neighbors:
		if not tilemap.get_used_cells(0).has(n):
			continue
		var enemy = EnemyManager.get_enemy_at(n)
		if not enemy:
			highlightgreen.set_cell(0, n, 0, highlightcoords)

	for enemy_cell in EnemyManager.enemies.keys():
		if tilemap.get_used_cells(0).has(enemy_cell):
			highlightred.set_cell(0, enemy_cell, 0, highlightcoords)
		for danger_cell in tilemap.get_surrounding_cells(enemy_cell):
			if not tilemap.get_used_cells(0).has(danger_cell):
				continue
			if not EnemyManager.enemies.has(danger_cell):
				highlightred.set_cell(0, danger_cell, 0, highlightcoords)
				
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
	if not tilemap.get_used_cells(0).has(target):
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
	position = tilemap.map_to_local(target)
	#animation/sound

func _attack(enemy) -> void:
	EnemyManager.kill(enemy)
	#animation/sound
