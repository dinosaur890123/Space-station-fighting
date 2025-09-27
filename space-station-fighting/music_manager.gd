extends Node

var player: AudioStreamPlayer = null
var _tween = null

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = 0.0

func play_track(path: String, loop := true, fade_in_time := 0.0):
	var stream = load(path)
	if not stream:
		push_error("MusicManager: can't load %s" % path)
		return
	if typeof(stream) == TYPE_OBJECT:
		if ("loop" in stream):
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
	if get_tree().has_method("create_tween"):
		if _tween:
			if _tween.has_method("kill"):
				_tween.kill()
			elif _tween.has_method("queue_free"):
				_tween.queue_free()
		_tween = get_tree().create_tween()
		_tween.tween_property(player, "volume_db", target_db, time_sec)
		if stop_on_end:
			_tween.connect("finished", Callable(self, "_on_fade_out_finished"))
	else:
		var tw = Tween.new()
		add_child(tw)
		_tween = tw
		tw.interpolate_property(player, "volume_db", player.volume_db, target_db, time_sec, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tw.start()
		if stop_on_end:
			tw.connect("tween_all_completed", Callable(self, "_on_fade_out_fwinished"))

func _on_fade_out_finished():
	if player:
		player.stop()
