extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/selena_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var folder := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if folder.is_empty(): return
	DirAccess.make_dir_recursive_absolute(folder)
	assert(root.get_texture().get_image().save_png(folder.path_join(name+".png")) == OK)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game._close_modal()
	var before: Dictionary = game.store.profile.duplicate(true)
	for index in range(5):
		assert(game.tabs[index].tooltip_text == ["Formation","Equipment","Bag","Shop","More"][index])
		game.tabs[index].pressed.emit()
		assert(game.tab == [22,1,2,20,4][index])
		if index == 1: assert(game.character_page == 1)
		assert(game.store.profile == before)
	game._select_tab(24)
	var home: HomeScreen = game.panel.get_child(0)
	assert(home.hero_id == "selena_preview")
	assert(game.catalog.find_row("heroes","selena_preview").is_empty())
	for tier in [1,2,3]:
		for entry in Recruitment.pool(game.catalog,tier): assert(entry.id != "selena_preview")
	await capture("selena-home")
	home.actions.preview.pressed.emit()
	assert(game.modal.get_child(1).get_meta("hero_id") == "selena_preview")
	for index in range(1,6): assert(game.modal.find_child("ShowcaseTab%d" % index,true,false).disabled)
	await capture("selena-showcase")
	game.modal.find_child("PreviewReveal",true,false).pressed.emit()
	assert(game.modal.name == "ArtRevealPreview" and game.store.profile == before)
	await capture("selena-reveal-preview")
	game.modal.find_child("ArtPreviewClose",true,false).pressed.emit()
	assert(game.modal == null and game.store.profile == before)
	game._close_modal()
	game._select_tab(23)
	var gallery: HeroGallery = game.panel.get_child(0)
	gallery.set_filter("ownership","Previews")
	assert(gallery.visible_ids == ["selena_preview"])
	await capture("selena-gallery")
	gallery.card_buttons.selena_preview.pressed.emit()
	assert(game.modal != null)
	game._close_modal()
	assert(game.store.profile == before)
	game._select_tab(24)
	home = game.panel.get_child(0)
	home.actions.next.pressed.emit()
	assert(game.home_hero == "eira" and game.store.profile == before)
	game.store.read_only = true
	game._select_tab(23)
	gallery = game.panel.get_child(0)
	gallery.card_buttons.selena_preview.pressed.emit()
	assert(game.modal != null and game.store.profile == before)
	game._close_modal()
	game.store.read_only = false
	game._select_tab(0)
	game.selected_stage = 1
	game._begin()
	assert(game.battle != null and not game.battle.paused)
	var pending: Dictionary = game.store.profile.duplicate(true)
	for index in range(5):
		game.tabs[index].pressed.emit()
		assert(game.battle.paused and game.store.profile == pending)
		game._select_tab(0)
		assert(not game.battle.paused and game.store.profile == pending)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	print("PASS: Selena Home/Gallery/Showcase art preview, unavailable gameplay tabs, no summon entry, no save mutation and read-only browsing")
	quit()
