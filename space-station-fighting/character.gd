extends AnimatedSprite2D
@export var speed: float = 300 
@export var left_limit: float = 2
@export var right_limit: float = 1150


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var moving = false
	if Input.is_action_pressed("left"):
		position.x -= speed * delta  # Move up
		play("run")
		moving = true
	elif Input.is_action_pressed("right"):
		position.x += speed * delta
		play("run_forward")
		moving = true
		
	 
	position.x = clamp(position.x, left_limit, right_limit)
