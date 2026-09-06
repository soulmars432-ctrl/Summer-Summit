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
		Audio.play(23,26)
	elif state == TurnManager.State.Enemyturn:
		actions_label.text = "Enemy turn..."

func _play_roll_animation(final_value: int) -> void:
	var tween = create_tween()
	for i in 6:
		var progress = float(i) / 12
		var step_duration = lerp(0.04, 0.12, progress)
		var fake_value = randi_range(0, 5)
		
		tween.tween_callback(func(): die_sprite.texture = die_faces[fake_value])
		tween.tween_property(die_sprite, "scale:x", 0.0, step_duration * 2)
		tween.tween_property(die_sprite, "scale:x", 0.5, step_duration * 2)
		#tween.parallel().tween_property(die_sprite, "rotation_degrees",
			#die_sprite.rotation_degrees + randf_range(-25, 25), step_duration)
	
	tween.tween_callback(func(): die_sprite.texture = die_faces[final_value - 1])
	tween.tween_property(die_sprite, "rotation_degrees", 0, 0.15).set_trans(Tween.TRANS_BACK)
