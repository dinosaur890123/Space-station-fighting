extends AnimatedSprite2D
@export var speed: float = 300 
@export var right_limit: float = 0
@export var left_limit: float = 656
func _ready() -> void:
	pass 

func _process(delta):
	var moving = false
	var direction = 0
	if Input.is_action_pressed("left"):
		position.x -= speed * delta 
		play("run")
		moving = true
	elif Input.is_action_pressed("right"):
		position.x += speed * delta
		play("run_forward")
		moving = true
		
	 
	position.y += direction * speed * delta
	position.y = clamp(position.y, right_limit, left_limit)
