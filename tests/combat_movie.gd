extends SceneTree

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/combat_movie_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func run() -> void:
	var game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	await create_timer(.35).timeout
	assert(game.store.begin_run(1))
	var p: Dictionary = game.store.profile.duplicate(true)
	p.pending.seed = 7
	assert(game.store.commit(p))
	game._resume()
	var boss_start := -1.0
	var phase := 0
	for tick in range(2400):
		var battle: BattleModel = game.battle
		if battle.state != "battle":
			break
		if battle.wave == 2 and battle.move_clock <= 0:
			if boss_start < 0:
				boss_start = battle.time
			var age := battle.time - boss_start
			if phase == 0:
				if age > 1.7:
					battle.auto_attack = false
				if battle.enemy_clock >= 2.45 and battle.guard():
					phase = 1
			elif phase == 1 and age > 3.12:
				if battle.skill(1):
					phase = 2
			elif phase == 2 and age > 4.25:
				if battle.skill(2):
					battle.auto_attack = true
					phase = 3
			elif phase == 3 and battle.enemy_clock > 2.45:
				battle.guard()
		await physics_frame
	assert(game.battle.state == "won")
	assert(phase == 3)
	assert(game.store.profile.pending.is_empty())
	await create_timer(1.8).timeout
	assert(game.modal != null and not game.result_transition)
	game.audio.shutdown()
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: full stage with live ElevenLabs SFX, guard, heal, burst and delayed result")
	quit()
