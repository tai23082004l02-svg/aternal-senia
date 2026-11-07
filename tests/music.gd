extends SceneTree

var game

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/music_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var audio: AudioDirector = game.audio
	assert(audio.music != null and audio.music.stream.loop and audio.music.playing)
	assert(is_equal_approx(audio.music_level,.35) and not game.store.profile.settings.has("music_volume"))
	var original: Dictionary = game.store.profile.duplicate(true)
	game._audio_settings()
	assert(game.sound_sliders.has("music_volume"))
	game.sound_sliders.music_volume.value = .12
	assert(is_equal_approx(audio.music_level,.12) and game.store.profile == original)
	game._cancel_audio_settings()
	assert(is_equal_approx(audio.music_level,.35))
	game._audio_settings()
	game.sound_sliders.music_volume.value = .25
	game._apply_audio_settings()
	assert(is_equal_approx(game.store.profile.settings.music_volume,.25))
	assert(is_equal_approx(ProgressStore.new(game.catalog,game.store.path).profile.settings.music_volume,.25))
	original = game.store.profile.duplicate(true)
	game._audio_settings()
	game.sound_sliders.music_volume.value = .7
	game.store.fail_writes = true
	game._apply_audio_settings()
	assert(game.store.profile == original and game.audio_menu_open)
	game.store.fail_writes = false
	game._cancel_audio_settings()
	assert(is_equal_approx(audio.music_level,.25))
	assert(not game.store.audio_settings(true,.8,.35,1.1))
	assert(not game.store.audio_settings(true,.8,.35,NAN))
	# Exercise the real looping stream and mixer, independent of the save sync.
	game.set_physics_process(false)
	audio.configure(true,.8,.35,.35)
	audio.context("forest",false,false,false)
	await create_timer(3).timeout
	var menu_db := audio.music.volume_db
	audio.context("forest",false,true,true)
	await create_timer(.8).timeout
	assert(audio.music.volume_db < menu_db-7)
	audio.context("forest",false,false,false)
	await create_timer(.8).timeout
	assert(absf(audio.music.volume_db-menu_db)<.2)
	var record := AudioEffectRecord.new()
	record.format = AudioStreamWAV.FORMAT_16_BITS
	var bus := AudioServer.get_bus_index(AudioDirector.MUSIC_BUS)
	AudioServer.add_bus_effect(bus,record)
	record.set_recording_active(true)
	audio.music.seek(audio.music.stream.get_length()-.25)
	await create_timer(.8).timeout
	assert(audio.music.playing and audio.music.get_playback_position()<3)
	record.set_recording_active(false)
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(record.get_recording().save_to_wav(dir.path_join("music-loop.wav")) == OK)
	AudioServer.remove_bus_effect(bus,0)
	audio._notification(NOTIFICATION_APPLICATION_PAUSED)
	audio.context("forest",false,false)
	assert(audio.music.stream_paused)
	audio._notification(NOTIFICATION_APPLICATION_RESUMED)
	assert(not audio.music.stream_paused)
	audio.configure(false,.8,.35,.35)
	assert(not audio.music.playing)
	audio.configure(true,.8,.35,0)
	assert(not audio.music.playing)
	audio.apply_profile(game.store.profile)
	assert(audio.music.playing)
	game._audio_settings()
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var box: Control = game.modal.get_child(1)
	assert(box.get_global_rect().end.y<940)
	if not dir.is_empty(): root.get_texture().get_image().save_png(dir.path_join("music-settings.png"))
	game._cancel_audio_settings()
	audio.shutdown()
	assert(audio.music.stream == null and not audio.music.playing)
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: music loop/mixer, separate volume, old save default, preview/cancel/apply/failure/reload, ducking, background pause/resume, mute/zero/shutdown and settings bounds")
	quit()
