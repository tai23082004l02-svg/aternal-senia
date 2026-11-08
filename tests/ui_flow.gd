extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	assert(image.save_png(output.path_join(name + ".png")) == OK)

func run() -> void:
	var override_dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not override_dir.is_empty():
		output = override_dir
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	for tab_button in game.tabs:
		assert(tab_button.size == Vector2(93, 56), "Navigation must stay within portrait width")
		assert(tab_button.get_child(0).size == Vector2(31, 31), "Atlas texture must not expand tab artwork to source size")
	for skill_button in game.skill_buttons:
		assert(skill_button.size.x <= 160 and skill_button.icon != null, "Skill icon must preserve button layout")
	assert(game.hp_bar.size.y == 7 and game.sp_bar.size.y == 4, "Bars must not overlap warning text")
	await capture("01-campaign")
	for i in range(1, 5):
		game.tabs[i].pressed.emit()
		await capture("tab-%d" % i)
	game._select_tab(0)
	game._enter_stage(1)
	await capture("02-story")
	game._begin()
	assert(game.battle != null and game.battle.state == "battle")
	game.speed_button.pressed.emit()
	game.pause_button.pressed.emit()
	assert(game.battle.paused)
	game.pause_button.pressed.emit()
	game.skill_buttons[0].pressed.emit()
	await create_timer(.4).timeout
	await capture("03-combat")
	var captured_boss := false
	for i in range(1800):
		if game.battle.state != "battle":
			break
		if game.battle.enemy_clock > 2.45:
			game.guard_button.pressed.emit()
		if game.battle.hp < game.battle.stats.hp * .65:
			game.skill_buttons[1].pressed.emit()
		else:
			game.skill_buttons[2].pressed.emit()
			game.skill_buttons[0].pressed.emit()
		if game.battle.wave == 2 and not captured_boss and game.battle.move_clock <= 0:
			await capture("04-boss")
			captured_boss = true
		await physics_frame
	assert(game.battle.state == "won")
	await create_timer(.75).timeout
	await process_frame
	await capture("05-result")
	assert(game.store.profile.pending.is_empty())
	var before: int = game.store.profile.gold
	game._return_to_camp()
	game._select_tab(3)
	game._quest("first")
	assert(game.store.profile.gold > before)
	await capture("06-quest")
	game._select_tab(1)
	game._hero("ryn")
	assert(game.store.profile.hero == "ryn")
	await capture("07-ryn")
	print("PASS: rendered campaign, tabs, story, skill, pause, speed, boss, result, quest, hero switch")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	quit()
