extends Node2D
class_name Enemy

var cell: Vector2i
var just_spawned: bool = true
@export var is_dragon: bool = false
@export var is_orc: bool = false

func place_at(new_cell: Vector2i, tilemap: TileMapLayer) -> void:
	cell = new_cell
	position = tilemap.map_to_local(new_cell)
