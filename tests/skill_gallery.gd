extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/skill_gallery_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	game._refresh_hud()
	game.view._process(0)
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
	game.set_physics_process(false)
	game.view.set_process(false)
	for skill in range(3):
		var model := BattleModel.new(game.catalog)
		model.start({"id": "skill_gallery_%d" % skill, "stage": 1, "seed": 7, "stats": game.catalog.stats(game.store.profile)})
		model.wave = 2
		model._spawn()
		model.auto_attack = false
		model.hp = 80
		game.battle = model
		game.view.battle = model
		game._refresh_panel()
		assert(model.skill(skill))
		var duration: float = model.last_action.marker + (.38 if skill == 1 else .18)
		for i in range(ceili(duration * 60)):
			model.advance(BattleModel.STEP)
			game.view._process(0)
		await capture(["skill-radiant", "skill-restoration", "skill-spirit"][skill])
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: three skill releases rendered from real model events")
	quit()
