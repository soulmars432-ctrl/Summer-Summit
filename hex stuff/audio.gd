extends Node
class_name SoundController

var sound_player = AudioStreamPlayer.new()
var sounds = []

# Initialize sounds at runtime
func _ready() -> void:
	add_child(sound_player)
	var menu_music = [AudioStreamOggVorbis.load_from_file("res://sound/MX_UI_Game Start Jingle.ogg")]
	var player_moves = []
	var player_death = []
	var enemy_death = []
	var enemy_spawn = []
	var dice_roll = []
	
	for i in 4:
		var n = i + 1
		var mvsnd = "res://sound/SFX_Player_Movement_" + str(n) + ".ogg"
		var pdsnd = "res://sound/SFX_Player_Player Death_" + str(n) + ".ogg"
		var dtsnd = "res://sound/SFX_Enemy_Enemy Killed_" + str(n) + ".ogg"
		var spsnd = "res://sound/SFX_Enemy_Spawn_" + str(n) + ".ogg"
		var drsnd = "res://sound/SFX_UI_Dice Roll_" + str(n) + ".ogg"
		
		player_moves.append(AudioStreamOggVorbis.load_from_file(mvsnd))
		player_death.append(AudioStreamOggVorbis.load_from_file(pdsnd))
		enemy_death.append(AudioStreamOggVorbis.load_from_file(dtsnd))
		enemy_spawn.append(AudioStreamOggVorbis.load_from_file(spsnd))
		dice_roll.append(AudioStreamOggVorbis.load_from_file(drsnd))
		
	sounds.append(menu_music)
	sounds.append(enemy_death)
	sounds.append(enemy_spawn)
	sounds.append(player_moves)
	sounds.append(player_death)
	sounds.append(dice_roll)

# Play sound
func play(type: int):
	# Menu Music - 0
	# Enemy    ## Death - 1     ## Spawn - 2
	# Player   ## Movement - 3  ## Death - 4
	# Dice Roll - 5
	if type == 0:
		sound_player.stream = sounds[type][0]
		sound_player.play()
	else:
		var n = randi_range(0,3)
		sound_player.stream = sounds[type][n]
		sound_player.play()
