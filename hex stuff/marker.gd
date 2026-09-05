extends Node2D
@export var tilemap: TileMap
var marker_scene: PackedScene = preload("res://hex stuff/marker.tscn")
var active_markers: Array = []

func _ready() -> void:
	EnemyManager.wave_incoming.connect(_on_wave_incoming)
	EnemyManager.wave_started.connect(_clear_markers)

func _on_wave_incoming(spawn_cells: Array) -> void:
	_clear_markers()
	for cell in spawn_cells:
		var marker = marker_scene.instantiate()
		add_child(marker)
		marker.position = tilemap.map_to_local(cell)
		active_markers.append(marker)

func _clear_markers() -> void:
	for m in active_markers:
		m.queue_free()
	active_markers.clear()
