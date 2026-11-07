extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/training_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func button(prefix: String) -> Button:
	for child in game.panel.get_children():
		if child is Button and child.text.begins_with(prefix):
			return child
	assert(false, "Missing button " + prefix)
	return null

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func run() -> void:
	var override_dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not override_dir.is_empty(): output = override_dir
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.heroes.eira.level = 4
	p.cleared = [1, 2, 3, 4, 5]
	assert(game.store.commit(p))
	game.tabs[1].pressed.emit()
	button("ĐIỂM THUỘC TÍNH").pressed.emit()
	assert(game.tab == 9)
	button("+1 điểm · +10").pressed.emit()
	button("+1 điểm · +1.5").pressed.emit()
	assert(AttributeTraining.remaining(game.store.profile, "eira") == 4)
	await capture("attribute-training")
	button("−1 điểm").pressed.emit()
	assert(AttributeTraining.allocation(game.store.profile, "eira").hp == 0)
	button("Hoàn toàn bộ điểm").pressed.emit()
	assert(AttributeTraining.remaining(game.store.profile, "eira") == 6)
	button("← Trở về nhân vật").pressed.emit()
	game._select_tab(4)
	button("SỔ TAY BOSS").pressed.emit()
	assert(game.tab == 10)
	await capture("boss-guide")
	# Mid-battle navigation pauses simulation and disables all build mutations.
	game._select_tab(0)
	game._enter_stage(1)
	game._begin()
	game._select_tab(9)
	assert(game.battle.paused and button("+1 điểm").disabled and button("Hoàn toàn bộ điểm").disabled)
	game._select_tab(10)
	assert(game.battle.paused)
	game._select_tab(0)
	assert(not game.battle.paused)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: training allocate/refund/reset, boss guide, mid-battle pause and build lock rendered")
	quit()
