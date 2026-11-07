extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/mission_polish_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func screen() -> MissionScreen: return game.panel.get_child(0)
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	MissionBoard.record(p, "offline", 1)
	MissionBoard.record(p, "wins", 3)
	MissionBoard.record(p, "kills", 10)
	assert(game.store.commit(p))
	game._select_tab(3)
	await capture("missions-polished")
	assert(MissionBoard.points(game.store.profile.missions.daily, "daily") == 40)
	assert("Nhận quà" in screen().chest_buttons[40].tooltip_text)
	assert("Chưa đạt" in screen().chest_buttons[60].tooltip_text)
	assert(not screen().claim_buttons.offline.disabled)
	var before: Dictionary = game.store.profile.duplicate(true)
	game._mission_tab(1)
	await capture("missions-polished-weekly")
	game._mission_tab(2)
	await capture("missions-polished-progress")
	assert(game.store.profile == before)
	game._mission_tab(0)
	screen().claim_buttons.offline.pressed.emit()
	assert(game.store.profile.missions.vip_exp == 5 and game.store.profile.gold == 30)
	assert(screen().claim_buttons.offline.disabled)
	screen().chest_buttons[20].pressed.emit()
	assert(game.modal != null)
	game._mission_claim_chest("daily", 20)
	assert(game.store.profile.gold == 50)
	assert("Đã nhận" in screen().chest_buttons[20].tooltip_text)
	await capture("missions-polished-claimed")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	game = null
	await process_frame
	await process_frame
	print("PASS: polished daily/weekly/progress UI preserves real points, chest states and atomic claims")
	quit()
