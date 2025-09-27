extends AnimatedSprite2D
@export var speed: float = 300 
@export var upper_limit: float = 62
@export var lower_limit: float = 656


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var moving = false
	var direction = 0
	if Input.is_action_pressed("left"):
		position.x -= speed * delta  # Move up
		play("run")
		moving = true
	elif Input.is_action_pressed("right"):
		position.x += speed * delta
		play("run")
		moving = true  
	if moving == false:
		play("standing")
	position.y += direction * speed * delta
	position.y = clamp(position.y, upper_limit, lower_limit)
