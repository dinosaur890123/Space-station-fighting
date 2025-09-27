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
	if GameData.overcharge_count >= 4:
		print("ERROR: Maximum Overcharge Reached!")
		return
	GameData.current_battery = GameData.max_battery
	GameData.overcharge_count += 1
	GameData.max_battery = GameData.MAX_CAPACITY - (GameData.MAX_CAPACITY * (0.25 * GameData.overcharge_count))
	GameData.current_battery = min(GameData.current_battery, GameData.max_battery)
	if GameData.overcharge_count >= 4:
		var btn = get_node_or_null("/root/Main/HBoxContainer/OverchargeButton")
		if btn:
			btn.disabled = true
	print("Emergency Overcharge Activated! (" + str(GameData.overcharge_count) + "/4)")
