extends AnimatedSprite2D

@export var speed: float = 120.0
@export var damage: float = 12.0
@export var ground_y: float = 485.0
@export var player_path: NodePath = ^"/root/Main/Character"

var _player: Node = null

func _ready():
	# Cache player (may be null if scene not ready yet)
	if has_node(player_path):
		_player = get_node(player_path)
	# Ensure we play default animation if not already
	if not is_playing():
		play()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	# Basic leftward movement
	position.x -= speed * delta
	# Clamp to ground if needed
	if position.y != ground_y:
		position.y = ground_y
	# If passed player x, apply damage then remove
	if _player and position.x <= _player.position.x:
		_apply_contact_damage()
		queue_free()
	# Despawn if far off screen
	if position.x < -200:
		queue_free()

func _apply_contact_damage():
	if GameData.shield_integrity > 0.0:
		var take = min(damage, GameData.shield_integrity)
		GameData.shield_integrity -= take
		damage -= take
	if damage > 0.0:
		GameData.health = max(0.0, GameData.health - damage)
