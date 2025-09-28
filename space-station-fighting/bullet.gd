extends Node2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 800

func set_direction(dir: Vector2):
	direction = dir

func _process(delta):
	if direction == Vector2.ZERO:
		return
	global_position += direction * speed * delta
	if global_position.x < 0 or global_position.x > 1200 or global_position.y < 0 or global_position.y > 720:
		queue_free()
	_check_bullet_hits()

func _check_bullet_hits():
	var bullet_area = get_node_or_null("shot/shot_area")
	if not (bullet_area and bullet_area is Area2D):
		return
	for body in get_tree().get_nodes_in_group("enemies"):
		if not body is Node2D:
			continue
		var dist = bullet_area.global_position.distance_to(body.global_position)
		if dist < 40:
			if body.has_method("take_hit"):
				body.take_hit(10.0)
            queue_free()
			break
