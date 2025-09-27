extends ProgressBar
@onready var shield_label = $ShieldLabel

func _ready():
	self.value_changed.connect(_on_value_changed)
	
func _on_value_changed(new_value):
	shield_label.text = str(int(new_value))
