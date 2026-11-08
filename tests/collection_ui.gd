extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/collection_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	if "reveal" in name: await create_timer(.4).timeout
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name+".png")) == OK)
func settle() -> void:
	for i in range(4): await process_frame

func pointer(position: Vector2, pressed: bool, touch: bool) -> void:
	if touch:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = root.get_screen_transform() * position
		event.pressed = pressed
		Input.parse_input_event(event)
	else:
		var event := InputEventMouseButton.new()
		event.position = root.get_screen_transform() * position
		event.global_position = root.get_screen_transform() * position
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		Input.parse_input_event(event)
	await process_frame

func swipe(position: Vector2, delta: Vector2, touch: bool) -> void:
	await pointer(position,true,touch)
	for i in range(1,9):
		var next := position+delta*float(i)/8
		if touch:
			var event := InputEventScreenDrag.new()
			event.index = 0
			event.position = root.get_screen_transform() * next
			event.relative = root.get_screen_transform().basis_xform(delta/8)
			Input.parse_input_event(event)
		else:
			var event := InputEventMouseMotion.new()
			event.position = root.get_screen_transform() * next
			event.global_position = root.get_screen_transform() * next
			event.relative = root.get_screen_transform().basis_xform(delta/8)
			event.button_mask = MOUSE_BUTTON_MASK_LEFT
			Input.parse_input_event(event)
		await process_frame
	await pointer(position+delta,false,touch)
	await settle()

func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var original: Dictionary = game.store.profile.duplicate(true)
	game._select_tab(23)
	var gallery: HeroGallery = game.panel.get_child(0)
	assert(gallery.visible_ids.size() == game.catalog.data.heroes.size())
	await capture("gallery-all")
	assert(gallery.cards.columns == 4 and gallery.card_buttons.size() == game.catalog.data.heroes.size())
	assert(gallery.collection_count.text == "Owned 1 / %d" % game.catalog.data.heroes.size())
	for button in gallery.card_buttons.values():
		assert(button.get_global_rect().size.x >= 100)
		assert(button.get_global_rect().end.x <= 516)
		assert(not button.disabled, "Locked heroes remain inspectable")
	assert(gallery.get_global_rect().end.y <= 864)
	gallery.affinity_buttons.fire.pressed.emit()
	assert(gallery.visible_ids.size() == 2 and gallery.affinity == "fire")
	gallery.reset_filters()
	gallery.view_button.pressed.emit()
	assert(gallery.detailed and gallery.cards.columns == 2)
	await capture("gallery-details")
	gallery.view_button.pressed.emit()
	assert(not gallery.detailed and gallery.cards.columns == 4)
	var owned_picker: OptionButton = gallery.pickers.ownership
	owned_picker.select(1)
	owned_picker.item_selected.emit(1)
	assert(gallery.visible_ids == ["eira"] and gallery.ownership == "Owned")
	var role_picker: OptionButton = gallery.pickers.role
	var healer_index: int = role_picker.get_meta("values").find("Healer")
	role_picker.select(healer_index)
	role_picker.item_selected.emit(healer_index)
	assert(gallery.visible_ids.is_empty() and gallery.role == "Healer")
	gallery.reset_filters()
	# A larger catalogue scrolls inside a fixed-height Gallery.
	var real_rows: Array = game.catalog.data.heroes.duplicate(true)
	for i in range(20):
		var row: Dictionary = real_rows[0].duplicate(true)
		row.id = "gallery_fixture_%d" % i
		row.name = "Preview %d" % i
		row.unlock = 99999
		row.gallery_order = 100 + i
		game.catalog.data.heroes.append(row)
	gallery.rebuild()
	await capture("gallery-scroll-top")
	var outer_scroll: int = game.scroll.scroll_vertical
	var drag_start: Vector2 = gallery.scroller.global_position + Vector2(55, 155)
	await swipe(drag_start, Vector2(0, -90), true)
	assert(gallery.scroller.scroll_vertical > 0 and game.modal == null)
	assert(game.scroll.scroll_vertical == outer_scroll and game.store.profile == original)
	gallery.scroller.scroll_vertical = 100000
	await capture("gallery-scroll-end")
	assert(gallery.scroller.scroll_vertical > 0)
	var final_card: Button = gallery.card_buttons.gallery_fixture_19
	assert(final_card.get_global_rect().intersects(gallery.scroller.get_global_rect()))
	assert(gallery.get_global_rect().end.y <= 864)
	game.catalog.data.heroes = real_rows
	gallery.reset_filters()
	gallery.card_buttons.ryn.pressed.emit()
	assert(game.modal != null)
	game._close_modal()
	assert(game.store.profile == original)
	gallery.set_filter("ownership","Locked")
	assert(gallery.visible_ids.size() == game.catalog.data.heroes.size()-1 and "eira" not in gallery.visible_ids)
	gallery.set_filter("affinity","fire")
	assert(gallery.visible_ids.size() == 2)
	gallery.set_filter("role","Healer")
	assert(gallery.visible_ids.is_empty() and gallery.empty_state.visible)
	await capture("gallery-empty")
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
	game.modal.find_child("RevealDetails", true, false).pressed.emit()
	assert(game.modal.name == "HeroShowcase" and game.store.profile == committed)
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
	print("PASS: four-column portrait gallery, detail toggle, 24-entry scroll, owned/locked and combined filters, showcase without mutation, skip/close/reload/replay without spending or granting twice")
	quit()
