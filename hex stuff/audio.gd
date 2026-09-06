extends Node
class_name SoundController

var sound_player = AudioStreamPlayer.new()
var music_player = AudioStreamPlayer.new()
var sounds = []

# Initialize sounds at runtime
func _ready() -> void:
	var dir = DirAccess.open("res://sound/")
	var sound_files = dir.get_files()
	var path = ""
	var i = 0
	for c in sound_files:
		if "import" not in c:
			print(str(i) + " " + c)
			i += 1
			path = "res://sound/" + c
			var s = AudioStreamOggVorbis.load_from_file(path)
			sounds.append(s)
	#print(sounds)
	add_child(sound_player)
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)

# Play sound
	# Menu - 0  # Music - 1
	# Enemy    ## Death - 2,5     
	# ## Dragon - 6,9   ## Spawn - 10,13
	# Player   ## Movement - 14,17,  ## Death - 18,21
	# Dice Roll - 22,25       # Start Game - 26
func play(range_begin: int, range_end: int):
	var idx = randi_range(range_begin, range_end)
	sound_player.stream = sounds[idx]
	sound_player.play()

func play_ambient(index: int) -> void:
	music_player.stream = sounds[index]
	music_player.play()

func _on_music_finished() -> void:
	music_player.play()

func stop_ambient() -> void:
	music_player.stop()
