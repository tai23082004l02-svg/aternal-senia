extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/ui_v2_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	if "reveal" in name: await create_timer(.4).timeout
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)
func check_buttons(parent: Node) -> void:
	for button in parent.find_children("*", "Button", true, false):
		if button.name.begins_with("ShowcaseHero_"): continue # Horizontally clipped portrait strip.
		assert(button.get_global_rect().position.x >= 24)
		assert(button.get_global_rect().end.x <= 516)
		assert(button.get_global_rect().end.y <= 864)
		assert(button.size.y >= UIDesignV2.HIT)
		assert(button.get_theme_font("font") == UIFonts.font("display"))
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game._close_modal()
	var original: Dictionary = game.store.profile.duplicate(true)
	assert(game.tab == 24 and game.panel.get_child(0) is HomeScreen)
	var home: HomeScreen = game.panel.get_child(0)
	await capture("home-v2")
	check_buttons(home)
	home.actions.next.pressed.emit()
	assert(game.home_hero == "eira" and game.store.profile == original)
	home = game.panel.get_child(0)
	home.actions.showcase.pressed.emit()
	assert(game.modal.name == "HeroShowcase")
	await capture("showcase-owned-v2")
	check_buttons(game.modal)
	game.modal.find_child("ShowcaseTab1", true, false).pressed.emit()
	await capture("showcase-skills-v2")
	var description_found := false
	for label in game.modal.find_children("*", "Label", true, false):
		if game.catalog.find_row("heroes", "eira").skill_descriptions.basic in label.text: description_found = true
	assert(description_found)
	assert(game.modal.find_child("ShowcaseTab4", true, false).disabled)
	assert(game.modal.find_child("ShowcaseTab5", true, false).disabled)
	game.modal.find_child("ShowcaseHero_ryn", true, false).pressed.emit()
	await capture("showcase-locked-v2")
	assert(game.modal.get_child(1).get_meta("hero_id") == "ryn")
	assert(not game.store.available_hero("ryn"))
	game.modal.find_child("ShowcaseTab3", true, false).pressed.emit()
	assert(game.tab == 1 and game.character_inspected == "ryn" and game.character_page == 6)
	assert(game.store.profile == original)
	game._select_tab(24)
	home = game.panel.get_child(0)
	home.actions.heroes.pressed.emit()
	assert(game.tab == 23)
	game._select_tab(24)
	home = game.panel.get_child(0)
	home.actions.summon.pressed.emit()
	assert(game.tab == 20 and game.shop_page == 2)
	assert(game.store.profile == original)
	var unlocked: Dictionary = original.duplicate(true)
	unlocked.cleared = [1]
	assert(game.store.commit(unlocked))
	game.home_hero = "eira"
	game._select_tab(24)
	home = game.panel.get_child(0)
	home.actions.next.pressed.emit()
	assert(game.home_hero == "ryn" and game.store.profile == unlocked)
	assert(PlayerIdentity.state(game.store.profile).avatar == PlayerIdentity.state(original).avatar)
	assert(game.store.profile.hero == original.hero)
	assert(game.store.commit(original))
	game._select_tab(24)
	assert(game.panel.get_child(0).hero_id == "eira", "A stale or locked session portrait falls back safely")
	# Reveal operates on committed results, including item/spirit paths.
	var p: Dictionary = original.duplicate(true)
	p.gold = 5000
	assert(game.store.commit(p) and Recruitment.summon(game.store, 10))
	var committed: Dictionary = game.store.profile.duplicate(true)
	game._replay_summon()
	await capture("reveal-v2")
	check_buttons(game.modal)
	game.modal.find_child("RevealSkip", true, false).pressed.emit()
	await capture("reveal-summary-v2")
	check_buttons(game.modal)
	assert(game.store.profile == committed)
	game._close_modal()
	game.presentation_options.reduced_effects = true
	game._replay_summon()
	var aura: SummonReveal.RevealAura
	for node in game.modal.get_child(1).get_children():
		if node is SummonReveal.RevealAura: aura = node
	assert(aura != null and not aura.animate)
	await capture("reveal-reduced-motion-v2")
	game._close_modal()
	game.store.read_only = true
	game._select_tab(24)
	HeroShowcase.show(game, "mira")
	game._close_modal()
	assert(game.store.profile == committed)
	game.store.read_only = false
	game._select_tab(0)
	game.selected_stage = 1
	game._begin()
	var pending: Dictionary = game.store.profile.pending.duplicate(true)
	assert(game.battle is TeamBattle)
	game._select_tab(24)
	assert(game.battle.paused)
	HeroShowcase.show(game, "eira")
	game._close_modal()
	assert(game.store.profile.pending == pending)
	game._select_tab(0)
	assert(not game.battle.paused and game.store.profile.pending == pending)
	assert(game.store.settle(pending.id, false, 0))
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	print("PASS: V2 Home/Showcase/Reveal routing, locked previews, real skill copy, read-only browsing, committed reveal, pending pause/resume and portrait bounds")
	quit()
