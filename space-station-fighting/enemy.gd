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
	var explosion_sprite = get_node_or_null("Explosion")
	if explosion_sprite:
		explosion_sprite.visible = false
		if not explosion_sprite.is_connected("animation_finished", Callable(self, "_on_explosion_finished")):
			explosion_sprite.connect("animation_finished", Callable(self, "_on_explosion_finished"))

func configure_variant(make_mega: bool):
	is_megabot = make_mega
	if is_megabot:
		max_health = 100.0
		health = 200.0
		damage = 60.0
		speed = 60.0
	else:
		max_health = 60.0
		health = 60.0
		damage = 20.0
		speed = 200.0
	_update_visual()
var move_direction: Vector2 = Vector2(-1, 0)

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
	if _exploding:
		return
	position += move_direction * speed * delta
	if abs(move_direction.y) < 0.01:
		if position.y != ground_y:
			position.y = ground_y
	if not _player:
		_player = get_tree().get_first_node_in_group("player")
	if _player:
		var contact_distance = 40.0
		var dist = global_position.distance_to(_player.global_position)
		if dist < contact_distance:
			_apply_contact_damage()
			_die()
	if position.x < -200:
		queue_free()
	if show_health_bar:
		queue_redraw()

func _apply_contact_damage():
	var remaining_damage = damage
	if GameData.shield_integrity > 0.0:
		var shield_take = min(remaining_damage, GameData.shield_integrity)
		GameData.shield_integrity -= shield_take
		remaining_damage -= shield_take
	if remaining_damage > 0.0:
		GameData.health = max(0.0, GameData.health - remaining_damage)

func take_hit(amount: float):
	health -= amount
	if health <= 0:
		_die()
	elif show_health_bar:
		queue_redraw()

func _die():
	if _exploding:
		return
	_exploding = true
    
	if is_megabot:
		GameData.signal_progress += 50
	else:
		GameData.signal_progress += 30
	var explosion_sprite = get_node_or_null("Explosion")
	if explosion_sprite and explosion_sprite is AnimatedSprite2D:
		explosion_sprite.visible = true
		var anims = explosion_sprite.sprite_frames.get_animation_names()
		if "explode" in anims:
			explosion_sprite.play("explode")
		else:
			queue_free()
	else:
		queue_free()

func _on_explosion_finished():
	var explosion_sprite = get_node_or_null("Explosion")
	if explosion_sprite and explosion_sprite is AnimatedSprite2D:
		if _exploding and explosion_sprite.animation == "explode":
			queue_free()

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
