extends Control

@onready var game_over_screen: Control = $GameOverScreen
@onready var result_message: Label = $GameOverScreen/VBoxContainer/ResultMessage
@onready var character: Node2D = $Character

var enemy_scene: PackedScene = preload("res://enemy.tscn")
var spawn_timer: float = 0.0
var spawn_interval: float = 3.0
var min_spawn_interval: float = 0.75
var spawn_accel: float = 0.02 

func _ready():
	GameData.reset()
	get_tree().paused = false


func _process(delta):
	if get_tree().paused:
		return
	_handle_enemy_spawning(delta)
	GameData.current_battery -= 3.0 * delta
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
	var power_needed = GameData.MAX_CAPACITY - GameData.shield_integrity
	var power_drawn = min(power_needed, GameData.current_battery)
	GameData.shield_integrity += power_drawn
	GameData.current_battery -= power_drawn
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
	# Spawn at right edge, random vertical jitter near ground (if you later add flying types adjust here)
	var viewport_width = get_viewport_rect().size.x
	enemy.position = Vector2(viewport_width + 50, 485)
	add_child(enemy)
	# Optional: ensure enemy renders behind UI (z_index if using CanvasItem layering)
	if enemy is CanvasItem:
		enemy.z_index = -1
func game_over(reason: String):
	if not game_over_screen: return
	result_message.text = reason
	game_over_screen.visible = true
	get_tree().paused = true

func _on_restart_button_pressed():
	# Unpause, reset state, then reload scene for a clean restart
	get_tree().paused = false
	if typeof(GameData) != TYPE_NIL:
		GameData.reset()
	get_tree().reload_current_scene()
