extends Node2D
@export var die_sprite: Sprite2D
@export var die_faces: Array[Texture2D]
@export var actions_label: Label

func _ready() -> void:
	TurnManager.turn_started.connect(_on_turn_started)
	TurnManager.roll_requested.connect(_play_roll_animation)
	TurnManager.action_taken.connect(_on_action_taken)
	call_deferred("_start_game")

func _start_game() -> void:
	TurnManager.start_player_turn()

func _on_action_taken(actions_left: int) -> void:
	actions_label.text = "Actions: %d" % actions_left

func _on_turn_started(state) -> void:
	if state == TurnManager.State.Rolling:
		actions_label.text = "Rolling..."
	elif state == TurnManager.State.Enemyturn:
		actions_label.text = "Enemy turn..."

func _play_roll_animation(final_value: int) -> void:
	for i in 8:
		die_sprite.texture = die_faces[randi_range(0, 5)]
		await get_tree().create_timer(0.2).timeout
	die_sprite.texture = die_faces[final_value - 1]
