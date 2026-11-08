extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/previews_%d" % Time.get_ticks_usec()))
	call_deferred("run")
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
	game.set_physics_process(false)
	game._close_modal()
	var before: Dictionary = game.store.profile.duplicate(true)
	var book: GameCatalog = game.catalog
	assert(book.errors.is_empty() and not book.find_row("heroes", "caelan").is_empty())
	assert(not game.store.available_hero("caelan"))
	assert(not Formation.assign(game.store, 0, "caelan"))
	var row := CharacterPreviews.find("caelan")
	assert(row.is_empty(),"Caelan has been promoted out of the preview registry")
	for tier in [1,2,3]:
		for entry in Recruitment.pool(book, tier): assert(entry.id != "caelan")
	var home: HomeScreen = game.panel.get_child(0)
	assert(not home.actions.has("preview"))
	HeroShowcase.show(game,"caelan")
	assert(game.modal != null and game.modal.get_child(1).get_meta("hero_id") == "caelan")
	await capture("caelan-showcase")
	for index in [1,2,3]: assert(not game.modal.find_child("ShowcaseTab%d" % index,true,false).disabled)
	for index in [4,5]: assert(game.modal.find_child("ShowcaseTab%d" % index,true,false).disabled)
	var disclosure := false
	for label in game.modal.find_children("*", "Label", true, false):
		if "Not owned" in label.text: disclosure = true
	assert(disclosure)
	game._close_modal()
	game._select_tab(23)
	var gallery: HeroGallery = game.panel.get_child(0)
	assert("caelan" in gallery.visible_ids and gallery.collection_count.text == "Owned 1 / 5")
	await capture("gallery-with-caelan")
	gallery.set_filter("ownership", "Previews")
	assert(gallery.visible_ids.is_empty())
	await capture("gallery-previews-only")
	gallery.set_filter("ownership", "Locked")
	assert("caelan" in gallery.visible_ids and gallery.visible_ids.size() == 4)
	HeroShowcase.manage(game, "caelan", 1)
	assert(game.tab == 1 and game.character_page == 1 and game.modal == null)
	assert(game.store.profile == before)
	# Old entry points resolve to current screens rather than duplicate legacy UI.
	game._select_tab(6)
	assert(game.tab == 1 and game.character_page == 5)
	game._select_tab(7)
	assert(game.tab == 18 and game.selected_spirit == before.assist)
	assert(game.store.profile == before)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	print("PASS: Caelan promoted to runtime without duplicate preview, no automatic ownership or summon entry, read-only browsing and old UI route redirects")
	quit()
