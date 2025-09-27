extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = 0
	if Input.is_action_pressed("Bup"):
		direction = -1  # Move up
	elif Input.is_action_pressed("Bdown"):
		direction = 1  # Move down	
	elif Input.is_action_pressed("Bswing"):
		$Bpaddle.play()
	elif Input.is_action_pressed("Bup") and Input.is_action_pressed("Bswing"):
		$Bpaddle.play()
		direction = -1 
	elif Input.is_action_pressed("Bswing") and Input.is_action_pressed("Bdown"):
		$Bpaddle.play()
		direction = 1 
	position.y += direction * speed * delta
	position.y = clamp(position.y, upper_limit, lower_limit)
