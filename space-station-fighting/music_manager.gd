extends Node

# MusicManager - Autoload singleton
# Usage (after adding this file as an Autoload named "MusicManager"):
#   MusicManager.play_track("res://audio/bgm.ogg", true, 1.0)
#   MusicManager.stop(1.0)
#   MusicManager.set_volume_db(-6)

var player: AudioStreamPlayer = null
var _tween = null

func _ready():
	# Create an AudioStreamPlayer if one doesn't exist in the scene tree.
	# This keeps the player persistent when this Node is autoloaded.
	player = AudioStreamPlayer.new()
	add_child(player)
	# default audible volume
	player.volume_db = 0.0

func play_track(path: String, loop := true, fade_in_time := 0.0):
	var stream = load(path)
	if not stream:
		push_error("MusicManager: can't load %s" % path)
		return
	# Try to set loop on the stream resource if supported (some stream types expose `loop`).
	# Use a safe check to avoid errors on stream types without that property.
	if typeof(stream) == TYPE_OBJECT:
		if ("loop" in stream):
			# some resources support a loop property
			stream.loop = loop
	player.stream = stream
	if fade_in_time > 0.0:
		player.volume_db = -80.0
	player.play()
	if fade_in_time > 0.0:
		_fade_to(0.0, fade_in_time)

func stop(fade_out_time := 0.0):
	if fade_out_time > 0.0:
		_fade_to(-80.0, fade_out_time, true)
	else:
		if player:
			player.stop()

func pause():
	if player:
		player.stream_paused = true

func resume():
	if player:
		player.stream_paused = false

func set_volume_db(db: float):
	if player:
		player.volume_db = db

func is_playing() -> bool:
	return player and player.playing

func _fade_to(target_db: float, time_sec: float, stop_on_end := false):
	# Use SceneTree tween when available (Godot 4), otherwise create a Tween node (Godot 3)
	if get_tree().has_method("create_tween"):
		# Godot 4 path
		if _tween:
			# try to stop/kill/cleanup previous tween in a safe, engine-agnostic way
			if _tween.has_method("kill"):
				_tween.kill()
			elif _tween.has_method("queue_free"):
				# Tween nodes (Godot 3) are Nodes and can be freed
				_tween.queue_free()
		_tween = get_tree().create_tween()
		_tween.tween_property(player, "volume_db", target_db, time_sec)
		if stop_on_end:
			_tween.connect("finished", Callable(self, "_on_fade_out_finished"))
	else:
		# Godot 3 fallback using Tween node
		var tw = Tween.new()
		add_child(tw)
		# Keep a reference so we can stop/cleanup next time
		_tween = tw
		tw.interpolate_property(player, "volume_db", player.volume_db, target_db, time_sec, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tw.start()
		if stop_on_end:
			tw.connect("tween_all_completed", Callable(self, "_on_fade_out_finished"))

func _on_fade_out_finished():
	if player:
		player.stop()
