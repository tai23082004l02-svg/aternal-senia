extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/caelan_ui_%d" % Time.get_ticks_usec()))
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
	game._select_tab(23)
	var gallery: HeroGallery = game.panel.get_child(0)
	gallery.set_filter("role","Vanguard")
	assert(gallery.visible_ids == ["caelan"])
	await capture("caelan-locked-card")
	gallery.showcase("caelan")
	await capture("caelan-showcase")
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1,2,3]
	assert(game.store.commit(p))
	game._confirm_caelan()
	game._recruit_caelan()
	assert(game.store.available_hero("caelan"))
	await capture("caelan-recruit")
	game._close_modal()
	game._open_gallery_hero("caelan")
	await capture("caelan-info")
	game._character_section(1)
	await capture("caelan-equipment")
	game._character_section(5)
	await capture("caelan-skills")
	p = game.store.profile.duplicate(true)
	p.hero = "caelan"
	p.formation = {"slots":["caelan","ryn","lyra","eira"],"auto_ult":false,"auto_next":false}
	assert(game.store.commit(p))
	game._select_tab(0)
	game.selected_stage = 1
	game._begin()
	game.battle.paused = true
	await capture("caelan-battle")
	game.battle.allies[0].energy = 100
	game.battle.paused = false
	assert(game.battle.ultimate(0))
	for tick in range(36): game.battle.advance(1.0/60)
	assert(game.battle.allies[0].barrier > 0)
	game.battle.paused = true
	await capture("caelan-unbroken-dawn")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	game.queue_free()
	await process_frame
	print("PASS: Caelan card/showcase/recruit/info/equipment/skills/four-hero battle and team shield render")
	quit()
