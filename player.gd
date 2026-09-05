extends Area2D

@export var area:TileMapLayer

func _process(delta: float) -> void:
	var movement:int = randi_range(1,6)
	if Input.is_action_just_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		if legal_move(mouse_pos,area.position, 8):
			position = mouse_pos.snapped(Vector2(128,128))


func legal_move(mouse_pos:Vector2, start_pos:Vector2, side:int):
	if mouse_pos.x < start_pos.x or mouse_pos.y < start_pos.y or mouse_pos.x > (start_pos.x + (side*128)) or mouse_pos.y > (start_pos.y + (side*128)):
		return false
	else:
		return true
