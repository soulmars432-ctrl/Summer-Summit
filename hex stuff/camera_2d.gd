extends Camera2D

var trauma := 0.0
var trauma_power := 2.0
var max_offset := Vector2(20, 20)
var max_roll := 0.1  # radians, subtle rotation adds a lot
var noise := FastNoiseLite.new()
var noise_y := 0.0

func _ready():
	noise.seed = randi()
	noise.frequency = 0.5

func _process(delta):
	if trauma > 0:
		trauma = max(trauma - delta * 1.0, 0.0)  # decay rate
		var amount = pow(trauma, trauma_power)
		noise_y += delta * 20.0
		rotation = max_roll * amount * noise.get_noise_2d(noise_y, 0)
		offset = Vector2(
			max_offset.x * amount * noise.get_noise_2d(noise_y, 1),
			max_offset.y * amount * noise.get_noise_2d(noise_y, 2)
		)
	else:
		offset = Vector2.ZERO
		rotation = 0.0

func add_trauma(amount: float):
	trauma = min(trauma + amount, 1.0)
