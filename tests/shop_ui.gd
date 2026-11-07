extends SceneTree

var game
var output := "user://first_light_previews"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/shop_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func screen() -> ShopScreen:
	return game.panel.get_child(0)

func run() -> void:
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty(): output = dir
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 1000
	assert(game.store.commit(p))
	game.tabs[0].pressed.emit()
	assert(game.tab == 20 and screen().tabs.size() == 6)
	var original: Dictionary = game.store.profile.duplicate(true)
	for i in range(6):
		screen().tabs[i].pressed.emit()
		assert(game.shop_page == i)
		await capture(["shop-gold", "shop-diamonds", "shop-summoning", "shop-event", "shop-packs", "shop-rewarded-ads"][i])
	assert(game.store.profile == original, "Browsing shop never grants or spends currency")
	for child in screen().body.get_children():
		if child is Button: assert(child.disabled, "Unconfigured rewarded ads cannot grant rewards")
	game._shop_section(0)
	game._shop_buy_confirm("xp")
	assert(game.modal != null)
	game._shop_buy("xp")
	assert(game.store.profile.gold == 900 and game.store.profile.xp == original.xp + 50)
	var after: Dictionary = game.store.profile.duplicate(true)
	game.store.fail_writes = true
	game._shop_buy("shards")
	assert(game.store.profile == after)
	game.store.fail_writes = false
	assert(not LocalShop.buy(game.store, "invalid"))
	assert(game.store.begin_run(1))
	assert(not LocalShop.buy(game.store, "xp"))
	var reloaded := ProgressStore.new(game.catalog, game.store.path)
	assert(reloaded.profile == game.store.profile)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	await RenderingServer.frame_post_draw
	print("PASS: six shop sections, confirm/gold purchase, write failure/reload, pending lock and inactive services")
	quit()
