extends SceneTree

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/vip_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)

func run() -> void:
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var store: ProgressStore = game.store
	var original := store.profile.duplicate(true)
	assert(store.valid(original) and not original.has("identity"))
	assert(PlayerIdentity.state(original).name == "Nhà lữ hành")
	assert(not PlayerIdentity.save(store, "\n", "eira"))
	assert(not PlayerIdentity.save(store, "Tester", "ryn"))
	assert(store.profile == original)
	assert(PlayerIdentity.save(store, "  Người chơi Việt  ", "eira"))
	var loaded := ProgressStore.new(game.catalog, store.path)
	assert(PlayerIdentity.state(loaded.profile).name == "Người chơi Việt")
	assert(loaded.profile.gold == original.gold and loaded.profile.pending == original.pending)
	var saved := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not PlayerIdentity.save(store, "Failed", "eira"))
	assert(store.profile == saved)
	store.fail_writes = false
	store.read_only = true
	assert(not PlayerIdentity.save(store, "Readonly", "eira"))
	store.read_only = false
	game._refresh_hud()
	await capture("vip-header")
	game.profile_button.pressed.emit()
	assert(game.modal.find_child("PlayerNameInput", true, false) != null)
	await capture("player-profile")
	for tier in range(1, 11):
		game._show_vip(tier)
		var title: Label = game.modal.find_child("VipTierTitle", true, false)
		assert(title.text == "VIP %d · Chưa mở" % tier)
		for level in range(1, 11):
			assert(game.modal.find_child("VipTier%d" % level, true, false) != null)
		assert(store.profile == saved)
	await capture("vip-tiers")
	game.queue_free()
	await process_frame
	print("PASS: legacy profile, Vietnamese name, owned avatars, persistence/write failure, VIP 1–10 read-only preview")
	quit()
