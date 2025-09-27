extends AnimatedSprite2D

@export var move_speed: float = 300.0
@export var left_limit: float = 2.0
@export var right_limit: float = 1150.0

var _facing_right: bool = true
var _attacking = false

func _ready() -> void:
	if not is_in_group("player"):
		add_to_group("player")
	var names = sprite_frames.get_animation_names()
	if not is_playing():
		if "standing" in names:
			play("standing")
		elif names.size() > 0:
			play(names[0])

func _process(delta: float) -> void:
	var dir_x: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var dir_y: float = Input.get_action_strength("down") - Input.get_action_strength("up")
	var moving: bool = abs(dir_x) > 0.1 or abs(dir_y) > 0.1
	if Input.is_action_just_pressed("attack_slash") and not _attacking == true:
		_attacking = true
		play("attack 1")
		return
	if _attacking == false:
		if abs(dir_x) > 0.1:
			_set_facing(dir_x > 0)
			_play_if_exists("run")
		elif moving:
			_play_if_exists("run")
		else:
			_play_if_exists("standing")
	position.x += dir_x * move_speed * delta
	position.y += dir_y * move_speed * delta
	position.x = clamp(position.x, left_limit, right_limit)
	position.y = clamp(position.y, 0, 700)
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

# --- Helpers ---
