extends Button
#var game_scene = preload("res://game.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.pressed.connect(_button_pressed)
	
	
func _button_pressed():
	get_tree().change_scene_to_file("res://hex stuff/hexmap.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
