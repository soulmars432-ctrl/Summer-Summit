extends Node
class_name SoundController

var dice_player = AudioStreamPlayer.new()
var sound_player = AudioStreamPlayer.new()
var music_player = AudioStreamPlayer.new()
var sounds = []

# Initialize sounds at runtime
func _ready() -> void:
	var dir = ResourceLoader.list_directory("res://sound/")
	var path
	var s
	var i = 0
	for c in dir:
		if "import" not in c:
			i += 1
			path = "res://sound/" + c
			s = load(path)
			sounds.append(s)
	add_child(sound_player)
	add_child(music_player)
	add_child(dice_player)
	music_player.finished.connect(_on_music_finished)

# Play sound
	# Menu - 1  # Music - 0 and 2
	# Enemy    ## Death - 3,6     
	# ## Dragon - 7,10   ## Spawn - 11,14
	# Player   ## Movement - 15,18,  ## Death - 19,22
	# Dice Roll - 23,26       # Start Game - 27
func play(range_begin: int, range_end: int):
	var idx = randi_range(range_begin, range_end)
	sound_player.stream = sounds[idx]
	sound_player.play()

func play_dice() -> void:
	var i = randi_range(23,26)
	dice_player.stream = sounds[i]
	dice_player.play()
	print(dice_player.playing)

func play_ambient(index: int) -> void:
	music_player.stream = sounds[index]
	music_player.play()

func _on_music_finished() -> void:
	music_player.play()

func stop_ambient() -> void:
	music_player.stop()
