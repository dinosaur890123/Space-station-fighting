extends Node2D

@onready var game_over_screen: Control = $GameOverScreen
@onready var result_message: Label = $GameOverScreen/VBoxContainer/ResultMessage
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

func _ready():
	$bullet.hide()
	GameData.reset()
	get_tree().paused = false
	randomize()
	var restart_btn = get_node_or_null("GameOverScreen/VBoxContainer/RestartButton")
	if restart_btn and not restart_btn.pressed.is_connected(_on_restart_button_pressed):
		restart_btn.pressed.connect(_on_restart_button_pressed)

var _bullet_direction: int = 1

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
	if Input.is_action_just_pressed("attack_air"):
		if character and character.has_method("get_facing_direction"):
			_bullet_direction = character.get_facing_direction()
		$bullet.global_position = character.global_position
		$bullet.show()
		_bullet_direction = -1 if $character.flip_h else 1
	if $bullet.visible:
		$bullet.global_position.x += 800 * delta * _bullet_direction
		if $bullet.global_position.x > right_limit or $bullet.global_position.x < left_limit:
			$bullet.hide()
	else:
		_check_bullet_hits()
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
	var viewport_width = get_viewport_rect().size.x
	var spawn_y = 485
	var spawn_x = viewport_width - 20
	enemy.position = Vector2(spawn_x, spawn_y)
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
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().paused = false
	_game_over = false
	if typeof(GameData) != TYPE_NIL:
		GameData.reset()
	get_tree().reload_current_scene()
