extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var button = Button.new()
	button.text = "Start Game"
	button.pressed.connect(_button_pressed)
	button.size = Vector2(300,70)
	add_child(button)
	
func _button_pressed():
	#get_tree().change_scene_to_file("")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
