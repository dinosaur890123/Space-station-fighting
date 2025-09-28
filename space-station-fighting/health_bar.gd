extends ProgressBar
@onready var health_label = $HealthLabel

func _ready():
	self.value_changed.connect(_on_value_changed)
	health_label.text = str("100")
	
	
func _on_value_changed(new_value):
	health_label.text = str(int(new_value))
