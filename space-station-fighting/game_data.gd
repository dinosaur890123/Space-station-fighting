extends Node
const MAX_CAPACITY = 100.0
var current_battery: float = 100.0
var max_battery: float = 100.0
var shield_integrity: float = 50.0
var health: float = 100.0
var signal_progress: float = 0.0
var overcharge_count: int = 0
var shield_boost_timer: float = 0.0
var signal_boost_timer: float = 0.0
func reset():
	current_battery = 100.0
	max_battery = 100.0
	shield_integrity = 100.0
	health = 100.0
	signal_progress = 0.0
	overcharge_count = 0
	shield_boost_timer = 0.0
	signal_boost_timer = 0.0
