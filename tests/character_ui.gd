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
	assert(screen().faces.size() == 3 and screen().section_buttons.size() == 5)
	screen().faces[1].pressed.emit()
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
	for i in range(5):
		screen().section_buttons[i].pressed.emit()
		assert(game.character_page == i)
		await capture(["character-info", "character-equipment", "character-level", "character-stars", "character-evolution"][i])
	assert(game.store.profile == original, "Browsing portraits/sections never mutates the profile")
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
		if control is Button: assert(control.disabled)
	var frozen: Dictionary = game.store.profile.duplicate(true)
	game._character_level("ryn", 1)
	assert(game.store.profile == frozen)
	game.tabs[2].pressed.emit()
	assert(not game.battle.paused)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: portrait rail, five sections, independent hero inspection, targeted upgrades/equip, evolution and pending lock rendered")
	quit()
