extends SceneTree

var game
var output := "user://first_light_previews/character-design"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/character_design_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func screen() -> CharacterScreen:
	return game.panel.get_child(0)

func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func run() -> void:
	if not OS.get_environment("FIRST_LIGHT_CAPTURE_DIR").is_empty(): output = OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1,2,3]
	p.gold = 10000
	p.xp = 10000
	p.shards = 100
	for id in ["staff_tide","armor_1","boots_3","armor_3"]:
		game.store._add_item(p,id)
		for item in p.items:
			if item.base == id: p.heroes.mira.equipment[game.catalog.find_row("items",id).slot] = item.uid
	assert(game.store.commit(p))
	game._select_tab(1)
	screen().face_buttons.mira.pressed.emit()
	assert(game.character_inspected == "mira" and game.store.profile.hero == "eira")
	var before: Dictionary = game.store.profile.duplicate(true)
	for i in range(5):
		screen().section_buttons[i].pressed.emit()
		assert(game.character_page == CharacterScreen.TAB_PAGES[i])
		for nav in game.tabs: assert(not nav.visible, "Character pages hide the main bottom navigation")
		await capture(["character-info","character-gear","character-development","character-skills","character-wardrobe"][i])
		for b in screen().section_buttons:
			assert(b.get_global_rect().end.x <= 540 and b.get_global_rect().end.y < game.tabs[0].global_position.y)
	game._character_section(2)
	assert(screen().development_buttons.size() == 3)
	screen().development_buttons[1].pressed.emit()
	assert(game.character_page == 4)
	screen().development_buttons[2].pressed.emit()
	assert(game.character_page == 3)
	game._character_section(5)
	game._character_skill_view("tree")
	var tree = screen().find_children("*","Control",true,false).filter(func(n): return n is CharacterScreen.TalentMap)[0]
	assert(tree.nodes.size() == 4)
	tree.nodes[1].pressed.emit()
	assert(game.character_talent_focus == "breaker")
	await capture("character-talents")
	game._character_section(6)
	game._preview_character_outfit("moon")
	await capture("character-wardrobe-preview")
	assert(game.store.profile == before, "Browsing all redesigned pages/tree/outfit preview is read-only")
	game._character_section(1)
	game._character_gear_picker("mira","boots")
	await capture("character-gear-picker")
	game._close_modal()
	var uid: String = game.store.profile.heroes.mira.equipment.boots
	game._character_choose_gear(uid,"mira",true)
	assert(game.store.profile.heroes.mira.equipment.boots == "" and game.store.profile.hero == "eira")
	game._character_choose_gear(uid,"mira",false)
	assert(game.store.profile.heroes.mira.equipment.boots == uid)
	game._select_tab(0)
	for nav in game.tabs: assert(nav.visible, "Main navigation returns outside Character")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: five bounded bottom tabs, three development pages, four real talent nodes, read-only browsing and inspected-hero gear picker")
	quit()
