extends Control
@onready var battery_bar = get_parent().get_node("BatteryGroup/BatteryBar")
@onready var shield_bar = get_parent().get_node("ShieldGroup/ShieldBar")
@onready var health_bar = get_parent().get_node("HealthGroup/HealthBar")
@onready var signal_label = get_parent().get_node("SignalGroup/SignalLabel")

func _process(delta):
	GameData.current_battery = clamp(GameData.current_battery, 0.0, GameData.max_battery)
	GameData.shield_integrity = clamp(GameData.shield_integrity, 0.0, GameData.MAX_CAPACITY)
	GameData.health = clamp(GameData.health, 0.0, GameData.MAX_CAPACITY)
	GameData.signal_progress = clamp(GameData.signal_progress, 0.0, GameData.MAX_CAPACITY)

	if is_instance_valid(battery_bar):
		battery_bar.max_value = GameData.max_battery
		battery_bar.value = GameData.current_battery
	if is_instance_valid(shield_bar):
		shield_bar.max_value = 100
		shield_bar.value = GameData.shield_integrity
	if is_instance_valid(health_bar):
		health_bar.max_value = 100
		health_bar.value = GameData.health
	if is_instance_valid(signal_label):
		signal_label.text = "Signal: %d / %d" % [int(GameData.signal_progress), int(GameData.MAX_CAPACITY)]
