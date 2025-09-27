extends AnimatedSprite2D

@export var speed: float = 120.0
@export var damage: float = 12.0
@export var ground_y: float = 485.0
@export var player_path: NodePath = ^"/root/Main/Character"

var _player: Node = null

func _ready():
	if has_node(player_path):
		_player = get_node(player_path)
	if not is_playing():
		play()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	position.x -= speed * delta
	if position.y != ground_y:
		position.y = ground_y
	if _player and position.x <= _player.position.x:
		_apply_contact_damage()
		queue_free()
	if position.x < -200:
		queue_free()

func _apply_contact_damage():
	if GameData.shield_integrity > 0.0:
		var take = min(damage, GameData.shield_integrity)
		GameData.shield_integrity -= take
		damage -= take
	if damage > 0.0:
		GameData.health = max(0.0, GameData.health - damage)
