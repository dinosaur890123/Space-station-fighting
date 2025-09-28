extends Node2D

@onready var game_over_screen: Control = $GameOverScreen
@onready var result_message: Label = $GameOverScreen/Panel/ResultMessage/ResultLabel
@onready var character: Node2D = $character
@export var left_limit: float = 2
@export var right_limit: float = 1150
var enemy_scene: PackedScene = preload("res://enemy.tscn")
var spawn_timer: float = 0.0
var spawn_interval: float = 3.0
var min_spawn_interval: float = 0.75
var spawn_accel: float = 0.02 
var battery_tick_timer: float = 0.0
const ENABLE_AUTO_SHIELD_RECHARGE := false
var _game_over: bool = false
var _bullet_direction: Vector2 = Vector2.ZERO 
var bullet_speed: float = 800 

func _ready():
	$bullet.hide()
	GameData.reset()
	get_tree().paused = false
	randomize()
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
	var signal_gain_rate = 0.2
	if GameData.shield_boost_timer > 0:
		signal_gain_rate *= 0.1 
	if GameData.signal_boost_timer > 0:
		signal_gain_rate *= 4.0
	GameData.signal_progress += signal_gain_rate * delta
	GameData.shield_boost_timer = max(0, GameData.shield_boost_timer - delta)
	GameData.signal_boost_timer = max(0, GameData.signal_boost_timer - delta)
	if ENABLE_AUTO_SHIELD_RECHARGE:
		var power_needed = GameData.MAX_CAPACITY - GameData.shield_integrity
		if power_needed > 0.0 and GameData.current_battery > 0.0:
			var recharge_rate = 5.0 * delta
			var to_transfer = min(power_needed, recharge_rate, GameData.current_battery)
			GameData.shield_integrity += to_transfer
			GameData.current_battery -= to_transfer
	if GameData.health <= 0.0:
		game_over("FAILURE: Health Depleted")
	elif GameData.current_battery <= 0.0:
		game_over("FAILURE: Power Depleted")
	
	if GameData.signal_progress >= GameData.MAX_CAPACITY:
		game_over("SUCCESS: Signal Transmission Complete!")

	if Input.is_action_just_pressed("attack_air") and not $bullet.visible:
		$bullet.global_position = $character.global_position
		$bullet.show()
		var dir_x := 0
		var dir_y := 0
		if Input.is_action_pressed("right"):
			dir_x = 1
			$bullet/shot.play("shot")
		elif Input.is_action_pressed("left"):
			dir_x = -1
			$bullet/shot.play("shot")
		if Input.is_action_pressed("up"):
			dir_y = -1
			$bullet/shot.play("shot")
		elif Input.is_action_pressed("down"):
			dir_y = 1
			$bullet/shot.play("shot")
		if dir_x == 0 and dir_y == 0:
			dir_x = -1 if $character.flip_h else 1
		_bullet_direction = Vector2(dir_x, dir_y).normalized()
		$bullet.rotation = _bullet_direction.angle()
		$bullet/shot.play("shot")
	if $bullet.visible:
		$bullet.global_position += _bullet_direction * bullet_speed * delta
		_check_bullet_hits()
		if ($bullet.global_position.x < left_limit or $bullet.global_position.x > right_limit
			or $bullet.global_position.y < 0 or $bullet.global_position.y > 720):
			$bullet.hide()
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
	var side = randi() % 4
	var spawn_x
	var spawn_y
	var move_dir = Vector2.ZERO
	match side:
		0:
			spawn_x = 0
			spawn_y = randf_range(0, viewport_height)
			move_dir = Vector2(1, 0)
		1:
			spawn_x = viewport_width
			spawn_y = randf_range(0, viewport_height)
			move_dir = Vector2(-1, 0)
		2:
			spawn_x = randf_range(0, viewport_width)
			spawn_y = 0
			move_dir = Vector2(0, 1)
		3:
			spawn_x = randf_range(0, viewport_width)
			spawn_y = viewport_height
			move_dir = Vector2(0, -1)
	enemy.position = Vector2(spawn_x, spawn_y)
	if enemy.has_method("set_move_direction"):
		enemy.set_move_direction(move_dir)
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
	var restart_btn = get_node_or_null("GameOverScreen/Panel/ResultMessage/HBoxContainer/RestartButton")
	if restart_btn:
		restart_btn.grab_focus()
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().paused = false
	_game_over = false
	if typeof(GameData) != TYPE_NIL:
		GameData.reset()
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
