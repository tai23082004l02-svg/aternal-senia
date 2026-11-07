extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/team_flow_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func win() -> void:
	for i in range(12000):
		game.battle.advance(1.0 / 60)
		if game.battle.state != "battle": break
	assert(game.battle.state == "won")
	game._finish()
	assert(game.store.profile.pending.is_empty())
	game._present_result()
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.cleared = [1]
	p.recruitment = Recruitment.fresh()
	p.recruitment.heroes = ["mira"]
	p.hero = "ryn"
	p.formation = {"slots":["ryn","mira","eira"],"auto_ult":true,"auto_next":false}
	for id in ["ryn","mira","eira"]: p.heroes[id].level = 8
	assert(game.store.commit(p))
	game.selected_stage = 6
	game._begin()
	game.battle.auto_next = true
	game.battle.auto_ultimate = false
	win()
	assert(game.battle is TeamBattle and game.battle.state == "battle" and game.store.profile.pending.stage == 7)
	assert(6 in game.store.profile.cleared)
	assert(game.battle.auto_next and not game.battle.auto_ultimate)
	assert(game.store.profile.pending.team.auto_next and not game.store.profile.pending.team.auto_ult)
	win()
	assert(game.store.profile.pending.is_empty() and game.modal != null)
	assert(7 in game.store.profile.cleared and game._next_team_stage() == 2)
	assert(game.battle.state == "won", "Stop before important chapter boss")
	var original: Dictionary = game.store.profile.duplicate(true)
	assert(game.store.settle(game.battle.run.id, true, game.battle.kills, game.battle.time))
	assert(game.store.profile == original)
	game._return_to_camp()
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.3).timeout
	game.queue_free()
	game = null
	await process_frame
	await process_frame
	print("PASS: real wins commit rewards then auto-advance 1-2 to 1-3, stop before chapter boss, no repeated payout")
	call_deferred("finish")

func finish() -> void:
	quit()
