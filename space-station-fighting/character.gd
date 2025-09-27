extends CharacterBody2D

# --- Movement / Physics Config ---
@export var move_speed: float = 300.0
@export var jump_speed: float = 500.0
@export var gravity: float = 1200.0
@export var left_limit: float = 2.0
@export var right_limit: float = 1150.0
@export var air_control_factor: float = 0.65
@export var coyote_time: float = 0.12 # Allow a short grace window after leaving ground to still jump
@export var jump_buffer_time: float = 0.12 # Allow slightly early jump input before landing

# --- Node References (auto-detect) ---
# Will try exact child name first; if missing, searches descendants at runtime.
@onready var sprite: AnimatedSprite2D = get_node_or_null("AnimatedSprite2D")

# --- Internal State ---
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _facing_right: bool = true

func _ready() -> void:
	if not sprite:
		sprite = _find_sprite_node(self)
	# Ensure an idle animation is playing if present.
	if sprite and not sprite.is_playing():
		var names = sprite.sprite_frames.get_animation_names()
		if "standing" in names:
			sprite.play("standing")
		elif names.size() > 0:
			# Fallback: play first available animation
			sprite.play(names[0])

func _physics_process(delta: float) -> void:
	# Apply gravity first.
	velocity.y += gravity * delta

	# Track grounded state for coyote time.
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = max(0.0, _coyote_timer - delta)

	# Decrease buffered jump timer.
	_jump_buffer_timer = max(0.0, _jump_buffer_timer - delta)
	var dir: float = Input.get_action_strength("right") - Input.get_action_strength("left")
	var target_speed: float = dir * move_speed
	var accel_factor: float = 1.0 if is_on_floor() else air_control_factor
	velocity.x = lerp(velocity.x, target_speed, accel_factor)
	var moving: bool = abs(velocity.x) > 5.0
	if moving:
		_set_facing(velocity.x > 0)
		_play_if_exists("run")
	elif is_on_floor():
		_play_if_exists("standing")

	# Handle jump input buffering.
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	# Execute jump if valid.
	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		velocity.y = -jump_speed
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_play_if_exists("run") # optional: could have a jump animation

	# Move using Godot's physics.
	move_and_slide()

	# Clamp horizontal world limits.
	global_position.x = clamp(global_position.x, left_limit, right_limit)

func _set_facing(right: bool) -> void:
	if right == _facing_right:
		return
	_facing_right = right
	if sprite:
		# AnimatedSprite2D flips with flip_h.
		sprite.flip_h = not right

func get_facing_direction() -> int:
	# Returns 1 for right, -1 for left (for bullet firing, etc.)
	return 1 if _facing_right else -1

func _play_if_exists(anim_name: String) -> void:
	if not sprite:
		return
	if anim_name in sprite.sprite_frames.get_animation_names():
		if sprite.animation != anim_name:
			sprite.play(anim_name)

func force_face_right(right: bool):
	# External helper if other systems need to enforce orientation.
	_set_facing(right)

# --- Helpers ---
func _find_sprite_node(n: Node) -> AnimatedSprite2D:
	for c in n.get_children():
		if c is AnimatedSprite2D:
			return c
		var deeper = _find_sprite_node(c)
		if deeper:
			return deeper
	return null
