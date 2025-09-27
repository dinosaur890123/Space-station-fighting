extends AnimatedSprite2D

@export var speed: float = 120.0
@export var damage: float = 10.0
@export var ground_y: float = 485.0
@export var player_path: NodePath = ^"/root/Main/character" # NOTE: fixed case to match actual node name
var max_health: float = 25.0
var health: float = 25.0
var is_megabot: bool = false
@export var show_health_bar: bool = true
@export var health_bar_width: float = 50.0
@export var health_bar_height: float = 5.0
@export var health_bar_offset_y: float = 60.0

var _player: Node = null

func _ready():
	# Primary lookup via exported path (now case-correct)
	if has_node(player_path):
		_player = get_node(player_path)
	# Fallback: look for a node in group 'player'
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
	# Secondary fallback: try common explicit path again (in case scene changes name)
	if not _player:
		_player = get_node_or_null("/root/Main/character")
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
	if show_health_bar:
		queue_redraw()

func _apply_contact_damage():
	if GameData.shield_integrity > 0.0:
		var take: float = min(damage, GameData.shield_integrity)
		GameData.shield_integrity -= take
		damage -= take
	if damage > 0.0:
		GameData.health = max(0.0, GameData.health - damage)

func take_hit(amount: float):
	health -= amount
	if health <= 0:
		queue_free()
	elif show_health_bar:
		queue_redraw()

func _draw():
	if not show_health_bar:
		return
	if health <= 0:
		return
	var ratio: float = clamp(health / max_health, 0.0, 1.0)
	var w: float = health_bar_width
	if is_megabot:
		w *= 1.25
	var h: float = health_bar_height
	var y: float = health_bar_offset_y
	if is_megabot:
		y *= 1.1
	var x: float = -w * 0.5
	var back_rect: Rect2 = Rect2(Vector2(x, y), Vector2(w, h))
	draw_rect(back_rect, Color(0,0,0,0.55), true)
	var fill_rect: Rect2 = Rect2(Vector2(x, y), Vector2(w * ratio, h))
	var col: Color = Color(0.25,1,0.25)
	if is_megabot:
		col = Color(1,0.25,0.25)
	draw_rect(fill_rect, col, true)
	draw_rect(back_rect, Color(0.9,0.9,0.9,0.8), false, 1.0)
