extends Node
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
