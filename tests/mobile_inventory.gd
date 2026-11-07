extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/mobile_bag_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func button(prefix: String) -> Button:
	for child in game.panel.get_children():
		if child is Button and child.text.begins_with(prefix): return child
	assert(false, "Missing button: " + prefix)
	return null

func run() -> void:
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty(): output = dir
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	assert(not game.skill_buttons[0].visible and not game.attack_button.visible)
	assert(game.tabs[2].position.y == 876 and game.tabs[2].size.y >= 44)
	for i in range(5):
		assert(game.tabs[i].tooltip_text == ["Shop", "Nhân vật", "Hành trình", "Phó bản", "Túi đồ"][i])
		game.tabs[i].pressed.emit()
		assert(game.tab == [20, 1, 0, 21, 2][i])
	game.tabs[0].pressed.emit()
	await capture("mobile-shop")
	game.tabs[3].pressed.emit()
	await capture("mobile-dungeons")
	game.tabs[2].pressed.emit()
	await capture("mobile-home")
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 10000
	p.shards = 100
	p.xp = 300
	p.cleared = [1, 2]
	p.expansion.cores = 12
	p.recruitment = Recruitment.fresh()
	p.recruitment.fragments.eira = 30
	game.store._add_item(p, "armor_4")
	game.store._add_item(p, "sword_2")
	assert(game.store.commit(p))
	var original: Dictionary = game.store.profile.duplicate(true)
	game.tabs[4].pressed.emit()
	await capture("mobile-bag")
	game._bag_open("equipment")
	await capture("mobile-equipment")
	game._bag_filter(2, false)
	game._bag_filter(4, true)
	await capture("mobile-filter")
	assert(game.store.profile == original, "Browsing and filtering cannot mutate storage")
	game._item_detail("item_1")
	assert(game.tab == 17)
	await capture("mobile-item-detail")
	game._equip("item_1")
	assert(game.store.profile.heroes.eira.equipment.armor == "item_1")
	game._bag_open("spirits")
	await capture("mobile-spirits")
	game._open_spirit("ash")
	game._assist("ash")
	assert(game.store.profile.assist == "ash")
	await capture("mobile-spirit-detail")
	game._bag_open("materials")
	await capture("mobile-materials")
	game._select_tab(19)
	var count: int = game.store.profile.items.size()
	game._forge("armor_1")
	assert(game.store.profile.items.size() == count + 1)
	var uid: String = game.store.profile.items[-1].uid
	game._item_detail(uid)
	game._dismantle(uid)
	assert(game.tab == 2 and game.bag_section == "equipment")
	assert(game.store.profile.items.size() == count)
	p = game.store.profile.duplicate(true)
	while p.items.size() < ProgressStore.BAG_CAP:
		game.store._add_item(p, "sword_2")
	assert(game.store.commit(p))
	game.bag_kind = "all"
	game.bag_rarity = 0
	game._bag_open("equipment")
	await capture("mobile-full-bag")
	assert(game.scroll.get_v_scroll_bar().max_value > game.scroll.size.y)
	assert(game.scroll.position.y + game.scroll.size.y <= game.tabs[4].position.y)
	count = game.store.profile.items.size()
	# Empty filter keeps navigation visible and does not discard items.
	game._bag_filter(1, false)
	game._bag_filter(4, true)
	assert(game.store.profile.items.size() == count)
	await capture("mobile-empty-filter")
	game._select_tab(15)
	game._map_stage(2)
	assert(game.tab == 0 and game.selected_stage == 2)
	game._enter_stage(2)
	game._begin()
	assert(game.battle != null and game.skill_buttons[0].visible)
	game._bag_open("equipment")
	assert(game.battle.paused)
	game._item_detail("item_1")
	assert(button("Cường hóa").disabled and button("Phân giải").disabled)
	var frozen: Dictionary = game.store.profile.duplicate(true)
	game._enhance("item_1", false)
	assert(game.store.profile == frozen)
	game._select_tab(0)
	assert(not game.battle.paused)
	await capture("mobile-battle")
	var reloaded := ProgressStore.new(game.catalog, game.store.path)
	assert(reloaded.profile == game.store.profile, "Existing save/UIDs/materials persist")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	await RenderingServer.frame_post_draw
	print("PASS: mobile navigation, inventory categories, filters, equip, spirit select, materials, forge/dismantle, persistence and battle lock")
	quit()
