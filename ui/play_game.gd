extends Button
#var game_scene = preload("res://game.tscn").instantiate()
#var music = load("res://sound/MX_Player_Main Theme.ogg")
#var smp = AudioStreamPlayer.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Audio.play(1,1)
	#add_child(smp)
	#smp.stream = music
	#smp.play()
	#print(music)
	#print(smp.playing)
	self.pressed.connect(_button_pressed)
	
	
func _button_pressed():
	get_tree().change_scene_to_file("res://hex stuff/hexmap.tscn")
	Audio.play(27,27)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
