extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/settings_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name+".png")) == OK)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	game._select_tab(4)
	var original: Dictionary = game.store.profile.duplicate(true)
	game._utility_settings()
	var screen: SettingsScreen = game.modal
	for page in ["home","audio","graphics","auto","notifications","account","other"]:
		screen.navigate(page)
		await capture("settings-"+page)
		assert(game.store.profile == original)
	screen.copy_email()
	assert(DisplayServer.clipboard_get() == "zorvykagames@gmail.com")
	screen.navigate("graphics")
	screen.controls.battery_saver.button_pressed = true
	assert(Engine.max_fps == 30)
	screen.controls.damage_numbers.button_pressed = false
	assert(not game.view.effects.show_numbers)
	game._close_modal()
	assert(game.presentation_options == GameOptions.DEFAULTS and Engine.max_fps == 60)
	game._utility_settings()
	screen = game.modal
	screen.navigate("audio")
	screen.sliders.ui_volume.value = .22
	assert(is_equal_approx(game.audio.ui_level,.22))
	game.store.fail_writes = true
	screen.save()
	assert(game.modal == screen and game.store.profile == original)
	game.store.fail_writes = false
	screen.save()
	assert(screen.page == "home" and is_equal_approx(game.store.profile.settings.ui_volume,.22))
	screen.navigate("other")
	assert(screen.body.get_child_count() >= 4)
	screen.navigate("account")
	screen.name_input.text = "ZORVYKA Tester"
	screen.save()
	assert(PlayerIdentity.state(game.store.profile).name == "ZORVYKA Tester")
	game._close_modal()
	game._select_tab(0)
	game._begin()
	assert(game.battle != null and not game.battle.paused)
	var pending: Dictionary = game.store.profile.pending.duplicate(true)
	game._utility_settings()
	screen = game.modal
	assert(game.battle.paused)
	screen.navigate("auto")
	assert(screen.controls.auto_ult.disabled and screen.primary.disabled)
	game._close_modal()
	assert(not game.battle.paused and game.store.profile.pending == pending)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	await create_timer(.3).timeout
	print("PASS: settings pages, live preview/cancel, failure/save, studio email clipboard, profile and battle pause locks")
	quit()
