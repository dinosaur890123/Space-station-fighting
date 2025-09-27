extends Node
func _on_divert_shield_button_pressed():
	GameData.signal_boost_timer = 0.0
	GameData.shield_boost_timer = 5.0
	print("Diverting power to shields!")
