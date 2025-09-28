extends Node

func _ready():
	_connect_button("/root/Main/OverchargeButton", _on_overcharge_button_pressed)
	_connect_button("/root/Main/DivertShieldButton", _on_divert_shield_button_pressed)
	_connect_button("/root/Main/DivertSignalButton", _on_divert_signal_button_pressed)

func _connect_button(path: String, method_ref):
	var btn = get_node_or_null(path)
	if btn and not btn.pressed.is_connected(method_ref):
		btn.pressed.connect(method_ref)

func _on_divert_shield_button_pressed():
	GameData.signal_boost_timer = 0.0
	GameData.shield_boost_timer = 5.0
	print("Diverting power to shields!")

func _on_divert_signal_button_pressed():
	GameData.shield_boost_timer = 0.0
	var health_cost = 30.0
	if GameData.health >= health_cost:
		GameData.health -= health_cost
		GameData.signal_progress += 80
		print("Signal boost: +80 signal for -30 health!")
	else:
		print("Not enough health for signal boost!")

func _on_overcharge_button_pressed():
	if GameData.overcharge_count >= 3:
		print("ERROR: Maximum Overcharge Reached!")
		var btn = get_node_or_null("/root/Main/OverchargeButton")
		if btn:
			btn.disabled = true
		return
	GameData.current_battery = GameData.max_battery
	GameData.overcharge_count += 1
	GameData.max_battery = GameData.MAX_CAPACITY * (1.0 - 0.25 * GameData.overcharge_count)
	GameData.max_battery = max(10.0, GameData.max_battery)
	GameData.current_battery = clamp(GameData.current_battery, 0.0, GameData.max_battery)
	if GameData.overcharge_count >= 3:
		var btn2 = get_node_or_null("/root/Main/OverchargeButton")
		if btn2:
			btn2.disabled = true
	print("Emergency Overcharge Activated! (" + str(GameData.overcharge_count) + "/3)")
