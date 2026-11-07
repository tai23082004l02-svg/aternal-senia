extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/utilities_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)
func screen() -> UtilitiesScreen:
	return game.panel.get_child(0)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	game._select_tab(4)
	assert(screen().entries.size() == 8)
	assert(screen().quest_badge == null)
	var original: Dictionary = game.store.profile.duplicate(true)
	await capture("utilities-menu")
	for id in ["quests", "story", "boss", "collection", "mail", "giftcode", "settings", "help"]:
		game._select_tab(4)
		screen().entries[id].pressed.emit()
		if id in ["quests", "story", "boss", "collection"]:
			assert(game.tab == {"quests": 3, "story": 16, "boss": 10, "collection": 8}[id])
		else:
			assert(game.modal != null)
			await capture("utilities-" + id)
			game._close_modal()
		assert(game.store.profile == original)
	var p: Dictionary = original.duplicate(true)
	for quest in game.catalog.data.quests: p.metrics[quest.metric] = maxi(p.metrics[quest.metric], quest.target)
	assert(game.store.commit(p))
	game._select_tab(4)
	assert(screen().quest_badge != null)
	assert(int(screen().quest_badge.text) == game.catalog.data.quests.size())
	await capture("utilities-ready")
	p = game.store.profile.duplicate(true)
	for quest in game.catalog.data.quests: p.claimed.append(quest.id)
	assert(game.store.commit(p))
	game._select_tab(4)
	assert(screen().quest_badge == null)
	game.queue_free()
	await process_frame
	print("PASS: three utility groups, eight destinations, no fake rewards, real unclaimed quest badge")
	quit()
