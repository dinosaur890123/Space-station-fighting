extends Control
const MAX_CAPACITY = 100.0
var current_battery: float = 100.0
var max_battery: float = 100.0
var shield_integrity: float = 50.0
var signal_progress: float = 0.0
var overcharge_count: int = 0
var shield_boost_timer: float = 0.0
var signal_boost_timer: float = 0.0