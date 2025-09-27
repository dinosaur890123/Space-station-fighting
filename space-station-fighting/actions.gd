extends Node

func _ready():
	_connect_button("/root/Main/HBoxContainer/OverchargeButton", _on_overcharge_button_pressed)
	_connect_button("/root/Main/HBoxContainer/DivertShieldButton", _on_divert_shield_button_pressed)
	_connect_button("/root/Main/HBoxContainer/DivertSignalButton", _on_divert_signal_button_pressed)

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
	var damage_to_deal = 20.0
	if GameData.shield_integrity >= damage_to_deal:
		GameData.shield_integrity -= damage_to_deal
	else:
		var remaining_damage = damage_to_deal - GameData.shield_integrity
		GameData.shield_integrity = 0
		GameData.health -= remaining_damage
	GameData.signal_boost_timer = 5.0
	print("Diverting power to signal!")

func _on_overcharge_button_pressed():
	# Limit to 3 safe overcharges (avoid reducing max battery to 0 which causes instant loss)
	if GameData.overcharge_count >= 3:
		print("ERROR: Maximum Overcharge Reached!")
		var btn = get_node_or_null("/root/Main/HBoxContainer/OverchargeButton")
		if btn:
			btn.disabled = true
		return
	# Refill then shrink capacity for future (25% reduction per use)
	GameData.current_battery = GameData.max_battery
	GameData.overcharge_count += 1
	GameData.max_battery = GameData.MAX_CAPACITY * (1.0 - 0.25 * GameData.overcharge_count)
	GameData.max_battery = max(10.0, GameData.max_battery) # safety floor
	GameData.current_battery = clamp(GameData.current_battery, 0.0, GameData.max_battery)
	if GameData.overcharge_count >= 3:
		var btn2 = get_node_or_null("/root/Main/HBoxContainer/OverchargeButton")
		if btn2:
			btn2.disabled = true
	print("Emergency Overcharge Activated! (" + str(GameData.overcharge_count) + "/3)")
