extends SceneTree
var game
var output := "user://first_light_previews/new-equipment"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/new_equipment_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png")) == OK)

func run() -> void:
	if not OS.get_environment("FIRST_LIGHT_CAPTURE_DIR").is_empty(): output = OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 20000
	p.shards = 300
	p.cleared = [1,2,3]
	for set_id in EquipmentSystem.ADDED_SETS:
		for kind in ["sword","spear","staff","armor","boots","accessory"]:
			assert(game.store._add_item(p,kind+"_"+set_id))
			var image: Image = game.icons.textures[kind+"_"+set_id].get_image()
			assert(not image.is_invisible())
			for point in [Vector2i(2,2),Vector2i(509,2),Vector2i(2,509),Vector2i(509,509)]:
				assert(image.get_pixelv(point).a < .01,"New equipment cells have transparent padding, not a gray background")
	for pair in [["eira","grove"],["ryn","storm"],["mira","moon"]]:
		for kind in [game.catalog.category(pair[0]),"armor","boots","accessory"]:
			for item in p.items:
				if item.base == kind+"_"+pair[1]: p.heroes[pair[0]].equipment[game.catalog.find_row("items",item.base).slot] = item.uid
	assert(game.store.commit(p))
	var before: Dictionary = game.store.profile.duplicate(true)
	for pair in [["eira","grove"],["ryn","storm"],["mira","moon"]]:
		game._select_tab(1)
		game._inspect_character(pair[0])
		game._character_section(1)
		assert(EquipmentSystem.set_counts(game.catalog,game.store.profile,pair[0])[pair[1]] == 4)
		await capture("equipment-"+pair[1])
		var base: String = game.catalog.category(pair[0])+"_"+pair[1]
		for item in game.store.profile.items:
			if item.base == base: game._character_item_detail(item.uid,pair[0])
		await capture("equipment-"+pair[1]+"-detail")
	assert(game.store.profile == before,"Browsing new equipment is read-only")
	game._bag_open("equipment")
	await capture("equipment-new-inventory")
	game._select_tab(19)
	await capture("equipment-grove-forge")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	await create_timer(.3).timeout
	print("PASS: three new equipped sets, real item detail and bonuses, independent inventory icons, grove forge and read-only browsing")
	quit()
