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
var right: bool = true # track facing (true=right, false=left)
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
		right = false
	if Input.is_action_pressed("right"):
		flip_h = false
		$shot.flip_h = false
		position.x += speed * delta
		play("run")
		moving = true
		right = true
	if Input.is_action_just_pressed("attack_air") and not $shot.visible:
		$shot.global_position = position
		$shot.flip_h = false  # start at player
		$shot.show()
	if $shot.visible:
		var dir := 1 if right else -1
		$shot.global_position.x += 800 * delta * dir
		if $shot.global_position.x > right_limit or $shot.global_position.x < left_limit:
			$shot.hide()
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
