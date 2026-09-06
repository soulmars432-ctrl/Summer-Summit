extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var width = get_viewport().size.x
	var height = get_viewport().size.y
	self.size = Vector2(width, height)
	self.color = Color(0.505, 0.368, 0.294, 1.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
