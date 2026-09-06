extends Node
class_name SoundController

var dice_player = AudioStreamPlayer.new()
var sound_player = AudioStreamPlayer.new()
var music_player = AudioStreamPlayer.new()
var music_player_2 = AudioStreamPlayer.new()
var sounds = []

# Initialize sounds at runtime
func _ready() -> void:
	music_player.set_max_polyphony(3)
	var dir = ResourceLoader.list_directory("res://sound/")
	var path
	var s
	var i = 0
	for c in dir:
		if "import" not in c:
			print(str(i) + " " + c)
			i += 1
			path = "res://sound/" + c
			s = load(path)
			sounds.append(s)
	add_child(sound_player)
	add_child(music_player)
	add_child(music_player_2)
	add_child(dice_player)
	music_player.finished.connect(_on_music_finished)
	music_player_2.finished.connect(_on_music_finished)

# Play sound
	# Menu - 2  # Music - 1, 3    # Ambience - 0
	# Enemy    ## Death - 4,7     
	# ## Dragon - 8,11   ## Spawn - 12,15
	# Player   ## Movement - 16,19,  ## Death - 20,23
	# Dice Roll - 24,27       # Start Game - 28
func play(range_begin: int, range_end: int):
	var idx = randi_range(range_begin, range_end)
	sound_player.stream = sounds[idx]
	sound_player.play()

func play_dice() -> void:
	var i = randi_range(24,27)
	dice_player.stream = sounds[i]
	dice_player.play()

func play_ambient(index: int) -> void:
	music_player.stream = sounds[index]
	music_player.play()

func _on_music_finished() -> void:
	music_player.play()
	music_player_2.play()
	
func play_music() -> void:
	music_player_2.stream = sounds[3]
	music_player_2.play()

func stop_ambient() -> void:
	music_player.stop()
