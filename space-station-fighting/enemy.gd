extends AnimatedSprite2D

@export var speed: float = 120.0
@export var damage: float = 20.0
@export var ground_y: float = 485.0
@export var player_path: NodePath = ^"/root/Main/character"
var max_health: float = 25.0
var health: float = 25.0
var is_megabot: bool = false
@export var show_health_bar: bool = true
@export var health_bar_width: float = 50.0
@export var health_bar_height: float = 5.0
@export var health_bar_offset_y: float = 60.0

var _player: Node = null
var _exploding: bool = false

func _ready():
	if has_node(player_path):
		_player = get_node(player_path)
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
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
		damage = 40.0
		speed = 90.0
	else:
		max_health = 25.0
		health = 25.0
		damage = 20.0
		speed = 120.0
	_update_visual()
var move_direction: Vector2 = Vector2(-1, 0) # default: left

func set_move_direction(dir: Vector2):
	move_direction = dir.normalized()


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
	position += move_direction * speed * delta
	# Only lock y position if moving horizontally (left/right)
	if abs(move_direction.y) < 0.01:
		if position.y != ground_y:
			position.y = ground_y
	# Otherwise, allow vertical movement
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
		if _player:
			print("Enemy: found player at runtime:", _player, "player_global=", _player.global_position)
	if _player:
		var contact_distance = 40.0
		var dist = global_position.distance_to(_player.global_position)
		print("Enemy: checking contact: dist=", dist, " contact_distance=", contact_distance, " enemy_global=", global_position, " player_global=", _player.global_position)
		if dist < contact_distance:
			print("Enemy: contact! Applying damage. Damage=", damage, " shield=", GameData.shield_integrity, " health=", GameData.health)
			_apply_contact_damage()
			print("Enemy: after damage shield=", GameData.shield_integrity, " health=", GameData.health)
			queue_free()
	if position.x < -200:
		queue_free()
	if show_health_bar:
		queue_redraw()

func _apply_contact_damage():
	print("Enemy._apply_contact_damage: entering; damage=", damage, " GameData=", GameData)
	var remaining_damage = damage
	print("Enemy._apply_contact_damage: before shield=", GameData.shield_integrity, " health=", GameData.health)
	if GameData.shield_integrity > 0.0:
		var shield_take = min(remaining_damage, GameData.shield_integrity)
		GameData.shield_integrity -= shield_take
		remaining_damage -= shield_take
		print("Enemy._apply_contact_damage: shield_take=", shield_take, " shield_after=", GameData.shield_integrity, " remaining_damage=", remaining_damage)
	if remaining_damage > 0.0:
		var old_health = GameData.health
		GameData.health = max(0.0, GameData.health - remaining_damage)
		print("Enemy._apply_contact_damage: applied_to_health=", remaining_damage, " health_before=", old_health, " health_after=", GameData.health)
	print("Enemy._apply_contact_damage: exiting; shield=", GameData.shield_integrity, " health=", GameData.health)

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
