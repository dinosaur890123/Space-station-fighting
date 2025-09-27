extends AnimatedSprite2D

@export var speed: float = 120.0
@export var damage: float = 10.0
@export var ground_y: float = 485.0
@export var player_path: NodePath = ^"/root/Main/Character"
var max_health: float = 25.0
var health: float = 25.0
var is_megabot: bool = false

var _player: Node = null

func _ready():
	if has_node(player_path):
		_player = get_node(player_path)
	if not is_playing():
		play()
	_update_visual()
	add_to_group("enemies")

func configure_variant(make_mega: bool):
	is_megabot = make_mega
	if is_megabot:
		max_health = 100.0
		health = 100.0
		damage = 20.0
		speed = 90.0
	else:
		max_health = 25.0
		health = 25.0
		damage = 10.0
		speed = 120.0
	_update_visual()

func _update_visual():
	if is_megabot:
		scale = Vector2(1.6,1.6)
		modulate = Color(1,0.4,0.4)
	else:
		scale = Vector2(1,1)
		modulate = Color(1,1,1)

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

func take_hit(amount: float):
	health -= amount
	if health <= 0:
		queue_free()
