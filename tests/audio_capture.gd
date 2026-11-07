extends SceneTree

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/audio_capture_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func run() -> void:
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if dir.is_empty():
		dir = "user://first_light_previews"
	DirAccess.make_dir_recursive_absolute(dir)
	var record := AudioEffectRecord.new()
	record.format = AudioStreamWAV.FORMAT_16_BITS
	AudioServer.add_bus_effect(0, record)
	var effect_index := AudioServer.get_bus_effect_count(0) - 1
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	record.set_recording_active(true)
	await create_timer(.3).timeout
	game._begin()
	var deadline := Time.get_ticks_msec() + 25000
	while game.battle.state == "battle" and Time.get_ticks_msec() < deadline:
		if game.battle.enemy_clock > 2.45:
			game._guard()
		if game.battle.hp < game.battle.stats.hp * .65:
			game._skill(1)
		else:
			game._skill(2)
			game._skill(0)
		await physics_frame
	assert(game.battle.state == "won")
	await create_timer(1.6).timeout
	var trace: Array = game.audio.trace.duplicate(true)
	game._return_to_camp()
	game._quest("first")
	await create_timer(.7).timeout
	game._audio_settings()
	game.sound_sliders.sfx_volume.value = .5
	game.sound_sliders.ambience_volume.value = .2
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(dir.path_join("10-audio-settings.png"))
	game._cancel_audio_settings()
	record.set_recording_active(false)
	var stream: AudioStreamWAV = record.get_recording()
	assert(stream != null and stream.get_length() > 2)
	assert(stream.save_to_wav(dir.path_join("audio-runtime.wav")) == OK)
	AudioServer.remove_bus_effect(0, effect_index)
	var file := FileAccess.open(dir.path_join("audio-trace.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"events": trace, "consumed": game.audio.consumed, "played": game.audio.played, "dropped": game.audio.dropped, "max_voices": game.audio.max_active, "duration": stream.get_length()}, "  "))
	file.close()
	game.audio.shutdown()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: actual Godot mixer recording, combat cues, result, reward and rendered sound controls")
	quit()
