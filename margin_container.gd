extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.size = Vector2(300,70)
	var center_x = get_viewport().size.x / 2 - self.size[0] / 2
	var center_y = get_viewport().size.y / 2 - self.size[1] / 2
	self.position = Vector2(center_x, center_y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
