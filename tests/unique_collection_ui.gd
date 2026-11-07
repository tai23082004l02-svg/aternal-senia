extends SceneTree
var game
var output := "user://first_light_previews/unique"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/unique_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

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
	p.gold = 8000
	p.shards = 100
	p.cleared = [1, 2, 3]
	p.recruitment = Recruitment.fresh()
	p.recruitment.seed = 17
	for item in game.catalog.data.items:
		game.store._add_item(p, item.id)
	p.collection_fragments.spirits.lumi = 20
	p.collection_fragments.spirits.ash = 10
	assert(game.store.commit(p))
	game._bag_open("equipment")
	var filters: Array = game.panel.find_children("*", "OptionButton", true, false)
	assert(filters.size() == 2 and filters[1].item_count == 6)
	for i in range(6):
		assert(filters[1].get_item_text(i) == ["Mọi độ hiếm", "Hiếm", "Sử thi", "Huyền thoại", "Thần thoại", "Thần thánh"][i])
	for i in range(1, 6):
		game._bag_filter(i, true)
		assert(game.bag_rarity == [3, 4, 5, 6, 7][i-1])
		await capture("unique-grade-%d" % i)
	game._bag_open("materials")
	await capture("unique-fragments")
	game.scroll.scroll_vertical = 650
	await capture("unique-equipment-fragments")
	game._item_detail("starter_ryn")
	await capture("unique-shared-spear")
	game._select_tab(11)
	var count: int = game.store.profile.items.size()
	game._summon_execute(10)
	assert(game.store.profile.items.size() >= count)
	for result in game.store.profile.recruitment.history:
		if result.kind == "item": assert(not result["duplicate"])
		else: assert(result["duplicate"] and result.fragment_amount == 10)
	await capture("unique-summon-results")
	game._close_modal()
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.3).timeout
	game.queue_free()
	await process_frame
	print("PASS: exactly five grade filters, per-ID fragment inventory, shared unique gear and all-owned x10 fragment results rendered")
	quit()
