extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/formation_layout_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func screen() -> FormationScreen: return game.panel.get_child(0)
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)
func choose_spirit(id: String) -> void:
	screen().spirit_button.pressed.emit()
	assert(game.modal != null)
	for button in game.modal.find_children("*", "Button", true, false):
		if button.text.ends_with(game.catalog.find_row("assists", id).name):
			assert(not button.disabled)
			button.pressed.emit()
			break
	assert(game.modal == null and game.store.profile.assist == id)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1,2]
	p.hero = "mira"
	p.assist = "ash"
	p.heroes.eira.level = 6
	p.formation = {"slots":["mira","eira","ryn"],"auto_ult":true,"auto_next":false}
	assert(game.store.commit(p))
	game._select_tab(22)
	await capture("formation-layout")
	assert(screen().slot_buttons.size() == 3 and screen().roster_buttons.size() == 4)
	assert(screen().roster_buttons.lyra.disabled)
	assert(screen().slot_buttons[0].global_position.x > screen().slot_buttons[1].global_position.x)
	assert(screen().slot_buttons[1].global_position.y == screen().slot_buttons[2].global_position.y)
	assert(screen().get_rect().size.y <= game.scroll.size.y)
	screen().slot_buttons[0].pressed.emit()
	screen().roster_buttons.ryn.pressed.emit()
	assert(game.store.profile.formation.slots == ["ryn","eira","mira"])
	assert(game.store.profile.hero == "ryn")
	choose_spirit("lumi")
	assert("Lumi" in screen().spirit_button.text)
	choose_spirit("ash")
	var before: Dictionary = game.store.profile.duplicate(true)
	game.store.fail_writes = true
	screen().roster_buttons.eira.pressed.emit()
	assert(game.store.profile == before)
	game.store.fail_writes = false
	var check: CheckButton = screen().get_node("auto_ult")
	check.button_pressed = false
	assert(not game.store.profile.formation.auto_ult)
	assert(game.store.profile.gold == p.gold and game.store.profile.shards == p.shards)
	assert(game.store.commit(p))
	game._select_tab(22)
	assert(game.store.begin_run(1))
	var pending: Dictionary = game.store.profile.pending.duplicate(true)
	game._refresh_panel()
	for button in screen().roster_buttons.values(): assert(button.disabled)
	assert(screen().get_node("auto_ult").disabled)
	screen().spirit_button.pressed.emit()
	for button in game.modal.find_children("*", "Button", true, false):
		if button.text != "Đóng": assert(button.disabled)
	assert(game.store.profile.pending == pending)
	game._close_modal()
	await capture("formation-layout-locked")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	game = null
	await process_frame
	await process_frame
	print("PASS: centered front/two rear layout, visible controls, owned roster clicks/swaps, spirit picker, atomic write and pending lock")
	quit()
