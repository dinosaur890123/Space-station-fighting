extends Control
@onready var game_over_screen = $GameOverScreen
@onready var result_message = $GameOverScreen/VBoxContainer/ResultMessage
func _ready():
	GameData.reset()
	get_tree().paused = false


func _process(delta):
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

func game_over(reason: String):
	result_message.text = reason
	game_over_screen.visible = true
	get_tree().paused = true


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
