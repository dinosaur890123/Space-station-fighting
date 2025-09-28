extends AnimatedSprite2D

@export var move_speed: float = 300.0
@export var left_limit: float = 2.0
@export var right_limit: float = 1150.0
var _facing_right: bool = true
var _attacking = false
var area_entered = false
func _ready() -> void:
	if not is_in_group("player"):
		add_to_group("player")
	var names = sprite_frames.get_animation_names()
	if not is_playing():
		if "standing" in names:
			play("standing")
		elif names.size() > 0:
			play(names[0])
var previous_position = global_position

func _process(delta: float) -> void:
	if area_entered == false:
		previous_position = global_position
		var input_vector := Vector2( Input.get_action_strength("right") - Input.get_action_strength("left"),Input.get_action_strength("down") - Input.get_action_strength("up"))
		var moving:= input_vector.length() > 0
		if Input.is_action_just_pressed("attack_slash") and not _attacking:
			_attacking = true
			play("attack 1")
			return
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()  # prevent faster diagonal movement
		if not _attacking:
			if moving:
				_set_facing(input_vector.x > 0)
				_play_if_exists("run")
			else:
				_play_if_exists("standing")
		var new_pos = position + input_vector * move_speed * delta
		position = new_pos  # move normally 
		position.x = clamp(position.x, left_limit, right_limit)
		position.y = clamp(position.y, 0, 700)
	if area_entered == true:
		global_position = previous_position
		$timer.start
func _on_animation_finished() -> void:
	if animation == "attack 1":
		_attacking = false
func _set_facing(right: bool) -> void:
	if right == _facing_right:
		return
	_facing_right = right
	flip_h = not right
func get_facing_direction() -> int:
	return 1 if _facing_right else -1

func _play_if_exists(anim_name: String) -> void:
	if anim_name in sprite_frames.get_animation_names():
		if animation != anim_name:
			play(anim_name)

func force_face_right(right: bool):
	_set_facing(right)

func _on_area_area_entered(area: Area2D) -> void:
	move_speed = 100


func _on_area_area_exited(area: Area2D) -> void:
	move_speed = 300 # Replace with function body.
