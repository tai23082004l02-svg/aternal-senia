extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/collection_ui_%d" % Time.get_ticks_usec()))
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
	var original: Dictionary = game.store.profile.duplicate(true)
	game._select_tab(23)
	var gallery: HeroGallery = game.panel.get_child(0)
	assert(gallery.visible_ids.size() == 4)
	await capture("gallery-all")
	gallery.set_filter("ownership","Locked")
	assert(gallery.visible_ids.size() == 3 and "eira" not in gallery.visible_ids)
	gallery.set_filter("affinity","fire")
	assert(gallery.visible_ids.size() == 2)
	gallery.set_filter("role","Healer")
	assert(gallery.visible_ids.is_empty())
	gallery.set_filter("role","All")
	gallery.showcase("ryn")
	await capture("gallery-locked-showcase")
	game._close_modal()
	assert(game.store.profile == original)
	var p: Dictionary = original.duplicate(true)
	p.gold = 5000
	assert(game.store.commit(p))
	assert(Recruitment.summon(game.store,10))
	var committed: Dictionary = game.store.profile.duplicate(true)
	game._replay_summon()
	await capture("summon-reveal")
	var next_button: Button
	for node in game.modal.find_children("*","Button",true,false):
		if node.text == "Next": next_button = node
	assert(next_button != null)
	next_button.pressed.emit()
	assert(game.store.profile == committed)
	SummonReveal.show_summary(game,committed.recruitment.last_batch.entries)
	await capture("summon-summary")
	game._close_modal()
	game._replay_summon()
	game._close_modal()
	assert(game.store.profile == committed)
	var reloaded := ProgressStore.new(game.catalog,game.store.path)
	assert(reloaded.profile == committed)
	game.store = reloaded
	game._replay_summon()
	game._close_modal()
	assert(game.store.profile == committed)
	# Find a real seeded hero draw, then exercise its duplicate presentation.
	p = committed.duplicate(true)
	p.recruitment.pity = 19
	var found := false
	for seed in range(1,4097):
		p.recruitment.seed = seed
		var probe: Dictionary = p.duplicate(true)
		assert(Recruitment._draw(game.store,probe))
		if probe.recruitment.history[0].kind == "hero":
			found = true
			break
	assert(found and game.store.commit(p))
	assert(Recruitment.summon(game.store))
	committed = game.store.profile.duplicate(true)
	game._replay_summon()
	await capture("summon-hero-reveal")
	game._close_modal()
	assert(game.store.profile == committed)
	p = committed.duplicate(true)
	p.recruitment.seed += (p.recruitment.count - 1) * 7919
	p.recruitment.count = 0
	p.recruitment.pity = 19
	p.recruitment.erase("last_batch")
	assert(game.store.commit(p) and Recruitment.summon(game.store))
	committed = game.store.profile.duplicate(true)
	assert(committed.recruitment.history[0].get("duplicate",false))
	game._replay_summon()
	await capture("summon-duplicate-reveal")
	game._close_modal()
	game.store.read_only = true
	game._select_tab(23)
	gallery = game.panel.get_child(0)
	gallery.showcase("mira")
	game._close_modal()
	assert(game.store.profile == committed)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	print("PASS: owned/locked and combined filters, showcase without mutation, skip/close/reload/replay without spending or granting twice")
	quit()
