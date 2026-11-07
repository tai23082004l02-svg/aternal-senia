extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var book := GameCatalog.new()
	var dir := "user://first_light_tests/team_campaign_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	var store := ProgressStore.new(book, dir.path_join("save.json"))
	for stage_id in [1,6,7,2,8,9,3,10,11,4,12,13,5,14,15]:
		var roster := []
		for id in ["ryn","mira","eira"]:
			if store.available_hero(id): roster.append(id)
		while roster.size() < 3: roster.append("")
		var p := store.profile.duplicate(true)
		p.formation = {"slots":roster,"auto_ult":true,"auto_next":false}
		p.hero = roster[0]
		assert(store.commit(p))
		var upgraded := true
		while upgraded:
			upgraded = false
			for hero in roster:
				if not hero.is_empty() and store.upgrade("hero", 0, hero): upgraded = true
		for quest in book.data.quests:
			if quest.id not in store.profile.claimed and store.profile.metrics[quest.metric] >= quest.target: assert(store.claim_quest(quest.id))
		assert(store.begin_run(stage_id))
		var model := TeamBattle.new(book)
		model.start(store.profile.pending)
		for i in range(12000):
			model.advance(1.0 / 60)
			if model.state != "battle": break
		print("Team story ", stage_id, " state ", model.state, " time ", model.time, " HP ", model.hp)
		assert(model.state == "won")
		assert(store.settle(model.run.id, true, model.kills, model.time))
		store = ProgressStore.new(book, store.path)
		assert(not store.read_only)
	print("PASS: 15 team Story stages with earned rewards, automatic owned roster and reloads")
	quit()
