extends Control

@onready var game_over_screen: Control = $GameOverScreen
@onready var result_message: Label = $GameOverScreen/VBoxContainer/ResultMessage
@onready var character: Node2D = $Character

var enemy_scene: PackedScene = preload("res://enemy.tscn")
var spawn_timer: float = 0.0
var spawn_interval: float = 3.0
var min_spawn_interval: float = 0.75
var spawn_accel: float = 0.02 
var battery_tick_timer: float = 0.0
const ENABLE_AUTO_SHIELD_RECHARGE := false

func _ready():
	GameData.reset()
	get_tree().paused = false

func _process(delta):
	if get_tree().paused:
		return
	_handle_enemy_spawning(delta)
	battery_tick_timer += delta
	if battery_tick_timer >= 4.0:
		var ticks = int(battery_tick_timer / 4.0)
		GameData.current_battery = max(0.0, GameData.current_battery - ticks * (GameData.max_battery * 0.01))
		battery_tick_timer -= ticks * 4.0
	var shield_drain_rate = 0.8
	if GameData.shield_boost_timer > 0:
		shield_drain_rate *= 0.5
	if GameData.shield_integrity > 0:
		GameData.shield_integrity -= shield_drain_rate * delta
	else:
		GameData.health -= shield_drain_rate * delta
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
	if GameData.health <= 0.0 or GameData.current_battery <= 0.0:
		game_over("FAILURE: Health Depleted or Power Depleted")
	
	if GameData.signal_progress >= GameData.MAX_CAPACITY:
		game_over("SUCCESS: Signal Transmission Complete!")

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
	enemy.position = Vector2(viewport_width + 50, 485)
	add_child(enemy)
	if enemy is CanvasItem:
		enemy.z_index = -1
func game_over(reason: String):
	if not game_over_screen: return
	result_message.text = reason
	game_over_screen.visible = true
	get_tree().paused = true

func _on_restart_button_pressed():
	get_tree().paused = false
	if typeof(GameData) != TYPE_NIL:
		GameData.reset()
	get_tree().reload_current_scene()
