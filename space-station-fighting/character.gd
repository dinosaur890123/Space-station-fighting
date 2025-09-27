extends AnimatedSprite2D
@export var speed: float = 300 
@export var upper_limit: float = 62
@export var lower_limit: float = 656


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = 0
	if Input.is_action_pressed("left"):
		direction = -1  # Move up
	elif Input.is_action_pressed("right"):
		direction = 1  # Move down	
	position.y += direction * speed * delta
	position.y = clamp(position.y, upper_limit, lower_limit)
