extends Node2D
class_name Enemy

var cell: Vector2i

func place_at(new_cell: Vector2i, tilemap: TileMap) -> void:
	cell = new_cell
	position = tilemap.map_to_local(new_cell)
