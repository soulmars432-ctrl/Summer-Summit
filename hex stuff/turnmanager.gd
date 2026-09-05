extends Node2D
class_name Turnmanager

enum State {Playerturn, Enemyturn}

var state: State = State.Playerturn
var actions_remaining: int = 0

signal turn_started(state)
signal action_taken(actions_left)
signal player_turn_end
signal enemy_turn_end

func rolldie() -> int:
	return randi_range(1, 6)

func start_player_turn() -> void:
	state = State.Playerturn
	actions_remaining = rolldie()
	turn_started.emit(state)
	action_taken.emit(actions_remaining)

func spend_action() -> void:
	if state != State.Playerturn or actions_remaining <= 0:
		return
	actions_remaining -= 1
	action_taken.emit(actions_remaining)
	if actions_remaining == 0:
		end_player_turn()

func end_player_turn() -> void:
	player_turn_end.emit()
	start_enemy_turn()

func start_enemy_turn() -> void:
	state = State.Enemyturn
	turn_started.emit(state)
	#enemymanager stuff

func end_enemy_turn() -> void:
	enemy_turn_end.emit()
	start_player_turn()
