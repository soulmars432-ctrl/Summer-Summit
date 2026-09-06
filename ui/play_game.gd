extends Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play(1,1)
	self.pressed.connect(_button_pressed)
	
	
func _button_pressed():
	get_tree().change_scene_to_file("res://hex stuff/hexmap.tscn")
	Audio.play(28,28)
