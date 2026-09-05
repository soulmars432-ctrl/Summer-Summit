extends Area2D

@export var board:TileMapLayer

func _physics_process (_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		if is_on_board(get_global_mouse_position(), board):
			global_position = board.map_to_local(board.local_to_map(get_global_mouse_position())) 


func is_on_board(pos: Vector2, board:TileMapLayer) -> bool:
	if board.get_cell_source_id(board.local_to_map(board.to_local(pos))) == -1:
		return false
	else:
		return true
