extends Node2D
@onready var game_over_screen: Control = $GameOverScreen
@onready var result_message: Label = $GameOverScreen/Panel/ResultMessage/ResultLabel
@onready var character: Node2D = $character
@export var left_limit: float = 2
@export var right_limit: float = 1150
@onready var intro_screen = $IntroScreen
var enemy_scene: PackedScene = preload("res://enemy.tscn")
var spawn_timer: float = 0.0
var spawn_interval: float = 0.01
var min_spawn_interval: float = 0.1
var spawn_accel: float = 0.02 
var battery_tick_timer: float = 0.0
var _signal_tick_timer: float = 0.0
const ENABLE_AUTO_SHIELD_RECHARGE := true
var _game_over: bool = false
var _bullet_direction: Vector2 = Vector2.ZERO 
var bullet_speed: float = 800 
func _on_intro_start_pressed():
	if intro_screen:
		intro_screen.queue_free()
	get_tree().paused = false
	intro_screen = null
func _ready():
	$bullet.hide()
	GameData.reset()
	randomize()
	GameData.shield_integrity = 100.0
	if typeof(MusicManager) != TYPE_NIL and not MusicManager.is_playing():
		MusicManager.play_track("res://Bad Beat - Dyalla.mp3", true, 1.0)
	var restart_btn = get_node_or_null("GameOverScreen/Panel/ResultMessage/HBoxContainer/RestartButton")
	if restart_btn and not restart_btn.pressed.is_connected(Callable(self, "_on_restart_button_pressed")):
		restart_btn.pressed.connect(Callable(self, "_on_restart_button_pressed"))
	var quit_btn = get_node_or_null("GameOverScreen/Panel/ResultMessage/HBoxContainer/QuitButton")
	if quit_btn and not quit_btn.pressed.is_connected(Callable(self, "_on_quit_pressed")):
		quit_btn.pressed.connect(Callable(self, "_on_quit_pressed"))
func _process(delta):
	if get_tree().paused or _game_over:
		return
	_handle_enemy_spawning(delta)
	battery_tick_timer += delta
	if battery_tick_timer >= 4.0:
		var ticks = int(battery_tick_timer / 4.0)
		GameData.current_battery = max(0.0, GameData.current_battery - ticks * (GameData.max_battery * 0.01))
		battery_tick_timer -= ticks * 4.0
	_signal_tick_timer += delta
	if _signal_tick_timer >= 5.0:
		var ticks = int(_signal_tick_timer / 5.0)
		GameData.signal_progress += ticks * 10
		_signal_tick_timer -= ticks * 5.0
	GameData.shield_boost_timer = max(0, GameData.shield_boost_timer - delta)
	GameData.signal_boost_timer = max(0, GameData.signal_boost_timer - delta)
	if ENABLE_AUTO_SHIELD_RECHARGE:
		var power_needed = GameData.MAX_CAPACITY - GameData.shield_integrity
		if power_needed > 0.0:
			var recharge_rate = 0.2 * delta
			var to_transfer = min(power_needed, recharge_rate)
			GameData.shield_integrity += to_transfer
	if GameData.health <= 0.0:
		game_over("FAILURE: Health Depleted")
	elif GameData.current_battery <= 0.0:
		game_over("FAILURE: Power Depleted")
	
	if GameData.signal_progress >= GameData.MAX_CAPACITY:
		game_over("SUCCESS: Signal Transmission Complete!")
	if Input.is_action_just_pressed("attack_air") and not $bullet.visible:
		$bullet.global_position = $character.global_position
		$bullet.show()
		var direction := Vector2.ZERO
		if Input.is_action_pressed("right"):
			direction.x += 1
			$bullet/shot.play("shot")
		elif Input.is_action_pressed("left"):
			direction.x -= 1
			$bullet/shot.play("shot")
		if Input.is_action_pressed("up"):
			direction.y -= 1
			$bullet/shot.play("shot")
		elif Input.is_action_pressed("down"):
			direction.y += +1
			$bullet/shot.play("shot")
		if direction == Vector2.ZERO:
			direction.x = 1 if not $character.flip_h else -1
		_bullet_direction = direction.normalized()
		$bullet.rotation = _bullet_direction.angle()
		$bullet/shot.play("shot")
	if $bullet.visible:
		if _bullet_direction == Vector2.ZERO:
			_bullet_direction = Vector2(1, 0) # Default right if something goes wrong
		$bullet.position += _bullet_direction * bullet_speed * delta
		_check_bullet_hits()
	if $bullet.position.x < left_limit or $bullet.position.x > right_limit or $bullet.position.y < 0 or $bullet.position.y > 720:
		$bullet.hide()
		_bullet_direction = Vector2.ZERO  # Reset the direction
	if Input.is_action_just_pressed("attack_slash"):
		var melee_radius = 100.0
		var melee_damage = 5.0
		var char_pos = $character.global_position
		for body in get_tree().get_nodes_in_group("enemies"):
			if not body is Node2D:
				continue
			var dist = char_pos.distance_to(body.global_position)
			if dist < melee_radius:
				if body.has_method("take_hit"):
					body.take_hit(melee_damage)
	
func _check_bullet_hits():
	var bullet_area := $bullet.get_node_or_null("shot/shot_area")
	if not (bullet_area and bullet_area is Area2D):
		return
	for body in get_tree().get_nodes_in_group("enemies"):
		if not body is Node2D:
			continue
		var dist = bullet_area.global_position.distance_to(body.global_position)
		if dist < 40:
			if body.has_method("take_hit"):
				body.take_hit(10.0)
			$bullet.hide()
			_bullet_direction = Vector2.ZERO  # Reset the direction
			break

func _handle_enemy_spawning(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		_spawn_enemy()
		spawn_interval = max(min_spawn_interval, spawn_interval - spawn_accel)
		spawn_timer = spawn_interval

func _spawn_enemy():
	if not enemy_scene:
		return

	var enemy = enemy_scene.instantiate()
	var viewport_rect = get_viewport_rect()
	var viewport_width = viewport_rect.size.x
	var viewport_height = viewport_rect.size.y

	# Pick a random edge for spawning
	var side = randi() % 4
	var spawn_x
	var spawn_y
	match side:
		0:
			spawn_x = 0
			spawn_y = randf_range(0, viewport_height)
		1:
			spawn_x = viewport_width
			spawn_y = randf_range(0, viewport_height)
		2:
			spawn_x = randf_range(0, viewport_width)
			spawn_y = 0
		3:
			spawn_x = randf_range(0, viewport_width)
			spawn_y = viewport_height

	enemy.position = Vector2(spawn_x, spawn_y)

	# Random move direction
	var angle = randf_range(0, TAU)
	var move_dir = Vector2.RIGHT.rotated(angle).normalized()
	if enemy.has_method("set_move_direction"):
		enemy.set_move_direction(move_dir)

	# Configure variant
	var megabot = randf() < 0.15
	if megabot and enemy.has_method("configure_variant"):
		enemy.configure_variant(true)
	elif enemy.has_method("configure_variant"):
		enemy.configure_variant(false)

	add_child(enemy)
	if enemy is CanvasItem:
		enemy.z_index = 1
func game_over(reason: String):
	if _game_over:
		return
	_game_over = true
	if not game_over_screen:
		return
	result_message.text = reason
	game_over_screen.visible = true
	var color_rect = game_over_screen.get_node_or_null("ColorRect")
	if color_rect:
		if "SUCCESS" in reason:
			color_rect.color = Color(0, 0.7, 0.2, 0.5)
		else:
			color_rect.color = Color(0.7, 0, 0, 0.5)
	var restart_btn = get_node_or_null("GameOverScreen/Panel/ResultMessage/HBoxContainer/RestartButton")
	if restart_btn:
		restart_btn.grab_focus()
	get_tree().paused = true

func _on_restart_button_pressed():
	print("Restart button pressed!")
	get_tree().paused = false
	_game_over = false
	if typeof(GameData) != TYPE_NIL:
		GameData.reset()
		GameData.shield_integrity = 100.0
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
