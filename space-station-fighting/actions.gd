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
	var signal_cost = 20.0
	var heal_amount = 20.0
	if GameData.signal_progress >= signal_cost:
		GameData.signal_progress -= signal_cost
		GameData.health += heal_amount
		GameData.health = min(GameData.health, GameData.MAX_CAPACITY)
		print("Health boost: -20 signal, +20 health!")
	else:
		print("Not enough signal for health boost!")

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
	pass
