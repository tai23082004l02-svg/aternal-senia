extends SceneTree

var game
var typography
var vietnamese := RegEx.new()

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/english_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func inspect(node: Node) -> void:
	if (node is Label or node is Button) and node != game.profile_name:
		assert(vietnamese.search(node.text) == null, "Untranslated UI: " + node.text)
		for legacy in ["Tinh linh", "TINH LINH", "Tinh anh", "Mua", "Xem VIP", "Xem ›", "Kho tinh linh"]:
			assert(not legacy in node.text, "Untranslated UI: " + node.text)
		if node is Label and node.text.begins_with("HP"):
			assert(node.get_theme_font("font") == typography.SEMIBOLD)
	for child in node.get_children(): inspect(child)

func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	inspect(game.ui)
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)

func run() -> void:
	typography = root.get_node("Typography")
	vietnamese.compile("[àáảãạăâầấẩẫậằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđĐ]")
	assert(TranslationServer.get_locale().begins_with("en"))
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var original: Dictionary = game.store.profile.duplicate(true)
	assert(PlayerIdentity.state(original).name == "Traveler")
	assert(game.ui.theme.default_font == typography.REGULAR)
	assert(typography.DISPLAY.get_font_name().contains("Playfair"))
	assert(typography.BOLD.get_font_name().contains("Be Vietnam Pro"))
	for page in [0, 1, 2, 4, 11, 20, 21, 22]:
		game._select_tab(page)
		await capture("page-%d" % page)
	game._select_tab(0)
	game._show_player_profile()
	await capture("profile")
	var save: Button = game.modal.find_child("ProfileSave", true, false)
	assert(save.text.contains("SAVE PROFILE") and save.get_theme_font("font") == typography.BOLD)
	assert(save.get_global_rect().end.y <= 864)
	game._close_modal()
	game._utility_settings()
	for page in ["home", "audio", "graphics", "auto", "notifications", "account", "other"]:
		game.modal.navigate(page)
		await capture("settings-" + page)
	game._close_modal()
	assert(game.store.profile == original, "Browsing English UI must not write progress")
	assert(PlayerIdentity.save(game.store, "Người chơi Việt", "eira"))
	var reloaded := ProgressStore.new(game.catalog, game.store.path)
	assert(PlayerIdentity.state(reloaded.profile).name == "Người chơi Việt", "Never translate player names")
	game._select_tab(0)
	game._begin()
	var pending: Dictionary = game.store.profile.pending.duplicate(true)
	var enemy: Dictionary = game.battle.enemies[0]
	enemy.name = "Sói rừng"
	assert(root.get_node("Typography").enemy_name(enemy.name) == "Forest Wolf")
	await capture("legacy-enemy")
	assert(enemy.name == "Sói rừng" and game.store.profile.pending == pending)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	await create_timer(.2).timeout
	print("PASS: English default, bundled font roles, menus/settings/profile, no browse writes, Unicode player-name preservation")
	quit()
