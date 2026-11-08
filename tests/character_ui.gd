extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/character_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func screen() -> CharacterScreen:
	return game.panel.get_child(0)

func run() -> void:
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty(): output = dir
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	game.tabs[1].pressed.emit()
	assert(screen().faces.size() == game.catalog.data.heroes.size() and screen().section_buttons.size() == 5)
	var avatar_manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/avatars/manifest.json"))
	var avatar_source: Texture2D = load("res://" + avatar_manifest.source)
	assert(avatar_source.get_size() == Vector2(avatar_manifest.size[0], avatar_manifest.size[1]))
	for id in avatar_manifest.regions:
		var region: Array = avatar_manifest.regions[id]
		assert(Rect2(Vector2.ZERO, avatar_source.get_size()).encloses(Rect2(region[0],region[1],region[2],region[3])))
		assert(screen().face_buttons[id].get_child(0).selection_avatar, "Hero rail uses dedicated avatar art")
	screen().face_buttons.ryn.pressed.emit()
	assert(game.character_inspected == "ryn" and game.store.profile.hero == "eira")
	await capture("character-locked")
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 10000
	p.shards = 100
	p.xp = 10000
	p.cleared = [1, 2]
	p.expansion.cores = 20
	p.heroes.ryn.level = 14
	p.recruitment = Recruitment.fresh()
	p.recruitment.fragments.ryn = 100
	game.store._add_item(p, "armor_4")
	assert(game.store.commit(p))
	game._inspect_character("ryn")
	var original: Dictionary = game.store.profile.duplicate(true)
	for i in range(7):
		game._character_section(i)
		assert(game.character_page == i)
		await capture(["character-info", "character-equipment", "character-level", "character-stars", "character-evolution", "character-skills", "character-outfits"][i])
	assert(game.store.profile == original, "Browsing portraits/sections never mutates the profile")
	game._character_section(5)
	game._character_talent("ryn", "focus")
	assert(game.store.profile.expansion.builds.ryn.selected[0] == "focus" and game.store.profile.expansion.builds.eira.selected[0] == "")
	game._character_skill_level("ryn", 0)
	assert(game.store.profile.heroes.ryn.skills[0] == 2 and game.store.profile.hero == "eira")
	await capture("character-skills-learned")
	game._character_section(6)
	var before_look: Dictionary = game.store.profile.duplicate(true)
	game._preview_character_outfit("moon")
	assert(game.store.profile == before_look)
	game._apply_character_outfit("ryn", "moon")
	assert(Wardrobe.selected(game.store.profile, "ryn") == "moon" and game.store.profile.hero == "eira")
	await capture("character-outfit-applied")
	game._character_section(2)
	game._character_level("ryn", 1)
	assert(game.store.profile.heroes.ryn.level == 15 and game.store.profile.hero == "eira")
	game._character_section(3)
	game._character_stars("ryn")
	assert(game.store.profile.recruitment.awakening.ryn == 2)
	game._character_section(4)
	await capture("character-evolution-ready")
	game._character_evolve("ryn")
	assert(HeroEvolution.rank(game.store.profile, "ryn") == 2)
	await capture("character-evolved")
	game._character_section(1)
	game._character_equip("item_1", "ryn")
	assert(game.store.profile.heroes.ryn.equipment.armor == "item_1" and game.store.profile.hero == "eira")
	game._select_tab(0)
	game._enter_stage(1)
	game._begin()
	game.tabs[1].pressed.emit()
	assert(game.battle.paused)
	game._character_section(2)
	for control in screen().body.get_children():
		if control is Button and control.text.begins_with("Gain"): assert(control.disabled)
	var frozen: Dictionary = game.store.profile.duplicate(true)
	game._character_level("ryn", 1)
	assert(game.store.profile == frozen)
	game.tabs[2].pressed.emit()
	assert(game.tab == 0)
	assert(not game.battle.paused)
	assert(game.store.settle(game.store.profile.pending.id, false, 0))
	game._return_to_camp()
	p = game.store.profile.duplicate(true)
	p.heroes.ryn.level = 40
	p.recruitment.awakening.ryn = 1
	assert(game.store.commit(p))
	game.tabs[1].pressed.emit()
	game._inspect_character("ryn")
	game._character_section(0)
	var definition: Dictionary = game.catalog.find_row("heroes", "ryn")
	definition.rarity = 4
	game._inspect_character("ryn")
	for child in screen().find_children("*", "Control", true, false):
		if child is HeroPortrait: assert(not child.interactive, "Low-rarity template stays static")
	definition.rarity = 5
	game._inspect_character("ryn")
	assert(game.store.profile.recruitment.awakening.ryn == 1, "Touch is independent of expansion progress")
	for child in screen().find_children("*", "Control", true, false):
		if child is HeroPortrait:
			assert(child.interactive)
			child.begin_touch(Vector2(100, 100), 0)
			child.move_touch(Vector2(170, 70))
	await capture("character-5star-touch")
	game._character_section(6)
	await capture("character-5star-outfits")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: five main tabs/seven functional pages, skill tree, wardrobe, target actions, pending lock and native-five-star touch independent of expansion")
	quit()
