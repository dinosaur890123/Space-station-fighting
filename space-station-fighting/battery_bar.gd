extends ProgressBar

@onready var battery_label = $BatteryLabel

func _ready():
	self.value_changed.connect(_on_value_changed)
	battery_label.text = str("100")
	
	
func _on_value_changed(new_value):
	battery_label.text = str(int(new_value))
