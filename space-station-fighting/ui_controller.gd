extends Control
@onready var battery_bar = $BatteryGroup/BatteryBar
@onready var shield_bar = $ShieldGroup/ShieldBar
@onready var health_bar = $HealthGroup/HealthBar
@onready var signal_bar = $SignalGroup/SignalBar

func _process(delta):
	GameData.current_battery = clamp(GameData.current_battery, 0.0, GameData.max_battery)
	GameData.shield_integrity = clamp(GameData.shield_integrity, 0.0, GameData.MAX_CAPACITY)
	GameData.health = clamp(GameData.health, 0.0, GameData.MAX_CAPACITY)
	GameData.signal_progress = clamp(GameData.signal_progress, 0.0, GameData.MAX_CAPACITY)
	battery_bar.value = GameData.current_battery
	battery_bar.max_value = GameData.max_battery
	shield_bar.value = GameData.shield_integrity
	health_bar.value = GameData.health
	signal_bar.value = GameData.signal_progress
