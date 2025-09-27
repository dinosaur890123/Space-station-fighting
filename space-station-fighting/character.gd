extends AnimatedSprite2D

@export var speed: float = 300 
@export var left_limit: float = 2
@export var right_limit: float = 1150
@export var jump_speed: float = 500
@export var gravity: float = 1200
var velocity_y: float = 0 
var moving = false
var on_ground: bool = true  
var shot = false
func _ready() -> void:
	pass

func _process(delta):
	moving = false
	if Input.is_action_pressed("left"):
		flip_h = true
		$shot.flip_h = false
		position.x -= speed * delta
		play("run")
		moving = true
	if Input.is_action_pressed("right"):
		flip_h = false
		$shot.flip_h = false
		position.x += speed * delta
		play("run")
		moving = true
<<<<<<< Updated upstream
=======
		right = true
	if Input.is_action_just_pressed("attack_air") and not $shot.visible:
		$shot.global_position = position
		$shot.flip_h = false  # start at player
		$shot.show()
	if $shot.visible and right == true:
		$shot.global_position.x += 800 * delta  # move at bullet speed
		if $shot.global_position.x > right_limit:
			$shot.hide()  # hide when off-screen
	if $shot.visible and right == false:
		$shot.global_position.x -= 800 * delta  # move at bullet speed
		if $shot.global_position.x < left_limit:
			$shot.hide()  # hide when off-screen
>>>>>>> Stashed changes
	if Input.is_action_just_pressed("jump") and on_ground:
		velocity_y = -jump_speed
		on_ground = false
	if not on_ground:
		velocity_y += gravity * delta
		position.y += velocity_y * delta
	if position.y >= 485:
		position.y = 485
		velocity_y = 0
		on_ground = true
	if moving == false:
		play("standing")
	position.x = clamp(position.x, left_limit, right_limit)
