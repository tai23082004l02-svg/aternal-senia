extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/summon_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if not dir.is_empty():
		DirAccess.make_dir_recursive_absolute(dir)
		assert(root.get_texture().get_image().save_png(dir.path_join(name + ".png")) == OK)
func screen() -> SummonScreen:
	return game.panel.get_child(0).body.get_child(0)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 5000
	p.recruitment = Recruitment.fresh()
	p.recruitment.banner_pity = {"premium":7,"event":11}
	assert(game.store.commit(p))
	game._select_tab(11)
	assert(screen().find_child("BannerPityCounter",true,false) == null)
	assert(not screen().draw_ten.disabled)
	await capture("summon-normal")
	assert(screen().featured.size() == 5)
	for tile in screen().featured_buttons:
		assert(tile.get_global_rect().encloses(tile.get_child(1).get_global_rect()),"Reward artwork stays inside its clickable tile")
	assert(screen().kind_buttons[0].global_position.y == screen().kind_buttons[2].global_position.y)
	assert(screen().draw_one.size.x > 200 and screen().draw_ten.size.x > 200)
	screen().featured_buttons[0].pressed.emit()
	assert(game.modal != null and game.store.profile == p)
	game._close_modal()
	screen().preview_rewards()
	assert(game.modal != null and game.store.profile == p)
	await capture("summon-preview")
	game._close_modal()
	for index in [1, 2]:
		game._select_summon_kind(index)
		assert(screen().find_child("BannerPityCounter",true,false) != null)
		assert(screen().draw_one.disabled and screen().draw_ten.disabled)
		var labels := screen().pity_counter.find_children("*","Label",true,false)
		assert(labels[0].text.contains("7" if index == 1 else "11"))
		await capture("summon-premium" if index == 1 else "summon-event")
	assert(game.store.profile == p)
	var locale := TranslationServer.get_locale()
	var translation := Translation.new()
	translation.locale = "de"
	translation.add_message("PREMIUM\nGATE","DAS TOR DER\nFORTGESCHRITTENEN BESCHWÖRUNG")
	translation.add_message("Summon ×10\nLocked","Zehnfache Beschwörung\nNoch nicht verfügbar")
	translation.add_message("Pity: %d summons · Milestone pending","Garantiezähler: %d Versuche · Die Garantieschwelle ist noch nicht konfiguriert")
	TranslationServer.add_translation(translation)
	TranslationServer.set_locale("de")
	game._select_summon_kind(1)
	await capture("summon-long-text")
	assert(game.store.profile == p and screen().draw_ten.disabled)
	TranslationServer.remove_translation(translation)
	TranslationServer.set_locale(locale)
	game._select_summon_kind(0)
	screen().draw_ten.pressed.emit()
	assert(game.modal != null and game.store.profile == p)
	game._summon_execute(10)
	assert(game.store.profile.gold == 3800 and game.store.profile.recruitment.count == 10)
	await capture("summon-results")
	game._close_modal()
	game._summon_history()
	await capture("summon-history")
	game._close_modal()
	game._summon_rates()
	await capture("summon-rates")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.3).timeout
	game.queue_free()
	await process_frame
	print("PASS: normal/premium/event layout, scoped counters, unavailable banners, confirmed x10 and history")
	quit()
