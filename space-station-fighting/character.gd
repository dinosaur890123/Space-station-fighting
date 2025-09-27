extends AnimatedSprite2D

@export var speed: float = 300 
@export var left_limit: float = 2
@export var right_limit: float = 1150
@export var jump_speed: float = 500
@export var gravity: float = 1200
var velocity_y: float = 0
var _moving: bool = false
var on_ground: bool = true
var right: bool = true
const SHOT_DAMAGE: float = 15.0
@onready var shot_area: Area2D = $shot/shot_area
func _ready() -> void:
	$shot.hide()
	if shot_area and not shot_area.area_entered.is_connected(_on_shot_area_entered):
		shot_area.area_entered.connect(_on_shot_area_entered)
	_moving = false
func _process(delta):
	_moving = false
	if Input.is_action_pressed("left"):
		flip_h = true
		position.x -= speed * delta
		play("run")
		_moving = true
		right = false
	if Input.is_action_pressed("right"):
		flip_h = false
		position.x += speed * delta
		play("run")
		_moving = true
		right = true
	if Input.is_action_just_pressed("attack_air") and not $shot.visible:
		$shot.global_position = position
		$shot.show()
	if $shot.visible and right == true:
		$shot.global_position.x += 800 * delta
		if $shot.global_position.x > right_limit:
			$shot.hide() 
	if $shot.visible and right == false:
		$shot.global_position.x -= 800 * delta 
		if $shot.global_position.x < left_limit:
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
	if not _moving:
		play("standing")
	position.x = clamp(position.x, left_limit, right_limit)

func _on_shot_area_entered(area: Area2D):
	if not $shot.visible:
		return
	var node = area
	for i in 4:
		if node.has_method("take_hit"):
			node.take_hit(SHOT_DAMAGE)
			$shot.hide()
			return
		if node.get_parent():
			node = node.get_parent()
		else:
			break
