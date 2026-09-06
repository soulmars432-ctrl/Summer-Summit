extends Node2D
@export var tilemap: TileMap
var marker_scene: PackedScene = preload("res://hex stuff/marker.tscn")
var active_markers: Array = []

func _ready() -> void:
	EnemyManager.wave_incoming.connect(_on_wave_incoming)
	EnemyManager.wave_started.connect(_clear_markers)

func _on_wave_incoming(spawn_cells: Array, type: Array) -> void:
	_clear_markers()
	for i in range(spawn_cells.size()):
		var marker = marker_scene.instantiate()
		add_child(marker)
		marker.position = tilemap.map_to_local(spawn_cells[i])
		marker.get_child(0).play(type[i])
		active_markers.append(marker)

func _clear_markers() -> void:
	for m in active_markers:
		m.queue_free()
	active_markers.clear()
