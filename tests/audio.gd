extends SceneTree

var checks := 0
var audio: AudioDirector

func check(value: bool, label: String) -> void:
	checks += 1
	assert(value, label)

func cues(battle: BattleModel, key: String) -> Array:
	return battle.events.filter(func(event): return event.get("cue", "") == key)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var book := GameCatalog.new()
	DirAccess.make_dir_recursive_absolute("user://first_light_tests")
	var store := ProgressStore.new(book, "user://first_light_tests/audio_%d.json" % Time.get_ticks_usec())
	check(store.valid(store.profile), "Old settings without volume fields remain valid")
	check(store.audio_settings(true, .6, .2), "Persist independent levels")
	var reload := ProgressStore.new(book, store.path)
	check(is_equal_approx(reload.profile.settings.sfx_volume, .6), "SFX level reloads")
	check(not store.audio_settings(true, 1.1, .2), "Reject invalid level")
	var old: Dictionary = store.profile.duplicate(true)
	store.fail_writes = true
	check(not store.audio_settings(false, .1, .1) and store.profile == old, "Write failure preserves settings")
	store.fail_writes = false
	audio = AudioDirector.new()
	root.add_child(audio)
	audio.apply_profile(store.profile)
	check(audio.players.size() == 12, "Bounded voice pool")
	check(audio.manifest.cues.size() == 34, "Every named cue loads")
	for cue in audio.manifest.cues.values():
		for file in cue.files:
			check(audio.streams[file] != null, "Stream loads " + file)
	var run := {"id": "audio-run", "stage": 1, "seed": 44, "stats": book.stats(store.profile)}
	var battle := BattleModel.new(book)
	battle.start(run)
	battle.auto_attack = false
	battle.attack_clock = .9
	audio.begin_run(run.id)
	audio.consume(battle)
	battle.attack()
	battle.advance(.1)
	check(cues(battle, "swing_sword").is_empty(), "No early swing during anticipation")
	battle.advance(.05)
	check(cues(battle, "swing_sword").size() == 1, "Swing marker crosses once")
	check(cues(battle, "swing_sword")[0].action_id == 1, "Swing tagged with action ID")
	battle.advance(.10)
	var hits: Array = battle.events.filter(func(event): return event.kind in ["hit", "critical"])
	check(hits.size() == 1 and not hits[0].cue.is_empty(), "Impact cue owned by actual hit")
	check(hits[0].time >= .22 and hits[0].time <= .22 + BattleModel.STEP, "Impact time matches fixed-step marker")
	var rng_state := battle.rng.state
	audio.consume(battle)
	check(battle.rng.state == rng_state, "Presentation audio never consumes combat RNG")
	var count := audio.consumed
	audio.consume(battle)
	check(audio.consumed == count, "Repeated render/update does not duplicate cues")
	battle.paused = true
	var elapsed: float = battle.time
	battle.advance(.2)
	check(battle.time == elapsed, "Paused model emits no new timed sound")
	audio.context("forest", true)
	check(not audio.play("swing_sword"), "Paused battle rejects new combat sound")
	check(audio.play("ui_click"), "UI remains audible while combat paused")
	audio.context("forest", false)
	check(audio.ambience.playing, "Forest atmosphere loops")
	audio.context("ruins", false)
	check(not audio.ambience.playing, "Forest ambience stops in other regions")
	audio.configure(false, .6, .2)
	check(not audio.play("heal"), "Master mute prevents playback")
	for player in audio.players:
		check(not player.playing, "Mute stops existing voices")
	battle.paused = false
	battle.advance(.25)
	battle.attack_clock = .9
	battle.attack()
	battle.advance(.25)
	audio.consume(battle)
	var muted_cursor := audio.cursor
	audio.configure(true, .6, .2)
	audio.consume(battle)
	check(audio.cursor == muted_cursor, "Unmute does not replay muted backlog")
	# Pool saturation is independent of combat RNG and must retain warning/result priority.
	for player in audio.players:
		player.stop()
	audio.last_played.clear()
	for cue in ["swing_sword", "impact_sword", "swing_spear", "impact_spear", "swing_staff", "impact_staff", "lumi", "cast", "ash", "arrow_hit", "step", "enemy_down"]:
		audio.play(cue)
	check(audio.play("victory"), "Result preempts low-priority voice at pool capacity")
	check(audio.max_active <= 12, "Voice cap respected")
	audio.configure(false, .8, .3)
	# All speeds cross each action marker once; replay/seek of art cannot issue commands.
	for speed in [1, 2, 3]:
		var trial := BattleModel.new(book)
		trial.start(run)
		trial.auto_attack = false
		trial.speed = speed
		trial.attack_clock = .9
		trial.attack()
		for i in range(20):
			trial.advance(1.0 / 60)
		check(cues(trial, "swing_sword").size() == 1, "One swing at x%d" % speed)
		var impact: Array = trial.events.filter(func(event): return event.kind in ["hit", "critical"])
		check(impact.size() == 1, "One impact at x%d" % speed)
	var shield := BattleModel.new(book)
	run.stage = 2
	shield.start(run)
	shield.auto_attack = false
	shield.wave = 2
	shield._spawn()
	shield.advance(.02)
	check(cues(shield, "shield_on").size() == 1, "Shield transition has one cue")
	shield.skill(2)
	for i in range(34):
		shield.advance(1.0 / 60)
	check(cues(shield, "shield_break").size() == 1, "Burst breaks shield once")
	check(cues(shield, "cast").size() == 1 and cues(shield, "burst").size() == 1, "Cast and release are distinct events")
	audio.configure(true, .6, .2)
	audio.context("forest", true)
	for player in audio.players:
		player.stop()
	audio.last_played.clear()
	var preview_before := audio.played
	audio.audition()
	await create_timer(.06).timeout
	check(audio.played > preview_before, "Audition bypasses battle pause")
	audio.configure(false, .6, .2)
	var after_mute := audio.played
	audio.configure(true, .6, .2)
	await create_timer(.3).timeout
	check(audio.played == after_mute, "Mute cancels scheduled preview instead of replaying it")
	audio.shutdown()
	await create_timer(.2).timeout
	audio.queue_free()
	await process_frame
	# UI preview/apply/cancel has its own safe profile and pauses/resumes the battle.
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/audio_ui_%d" % Time.get_ticks_usec()))
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._begin()
	game._audio_settings()
	await process_frame
	await process_frame
	var sound_box: Control = game.modal.get_child(1)
	check(sound_box.position.x + sound_box.size.x <= 516, "Audio controls fit viewport width")
	check(game.battle.paused and game.audio_menu_open, "Audio panel pauses current battle")
	game.sound_sliders.sfx_volume.value = .25
	game.sound_sliders.ambience_volume.value = .1
	check(is_equal_approx(game.audio.effects_level, .25), "Volume previews live")
	game._cancel_audio_settings()
	check(not game.battle.paused and is_equal_approx(game.audio.effects_level, .8), "Cancel restores saved levels and resume")
	game._audio_settings()
	game.sound_sliders.sfx_volume.value = .4
	game.sound_sliders.ambience_volume.value = .15
	game._apply_audio_settings()
	check(is_equal_approx(game.store.profile.settings.sfx_volume, .4), "Apply commits new levels")
	game._audio_settings()
	game.store.fail_writes = true
	game.sound_sliders.sfx_volume.value = .1
	game._apply_audio_settings()
	check(game.audio_menu_open and game.modal != null, "Failed apply leaves controls open")
	check(is_equal_approx(game.store.profile.settings.sfx_volume, .4), "Failed apply preserves saved audio levels")
	game.store.fail_writes = false
	game._cancel_audio_settings()
	game._toggle_sound()
	check(not game.audio.enabled, "Mute button is immediate")
	game._toggle_sound()
	check(game.audio.enabled, "Unmute button restores sound")
	game.audio.shutdown()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: %d audio checks: timing, dedupe, mute, pause, priority, speeds, volumes and old saves" % checks)
	quit()
