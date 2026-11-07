extends SceneTree

func _initialize() -> void:
	var book := GameCatalog.new()
	DirAccess.make_dir_recursive_absolute("user://first_light_tests")
	var path := "user://first_light_tests/expanded_campaign_%d.json" % Time.get_ticks_usec()
	var store := ProgressStore.new(book, path)
	var stages := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 101, 102, 103]
	for stage in stages:
		assert(store.begin_run(stage))
		store = ProgressStore.new(book, path)
		var b := BattleModel.new(book)
		b.start(store.profile.pending)
		for tick in range(36000):
			if b.enemy_clock > 2.45: b.guard()
			if b.hp < b.stats.hp * .65: b.skill(1)
			elif not b.warning().begins_with("PHẢN"):
				b.skill(2)
				b.skill(0)
			b.advance(1.0 / 60)
			if b.state != "battle": break
		assert(b.state == "won", "Earned progression stage %d" % stage)
		assert(store.settle(b.run.id, true, b.kills, b.time))
		for quest in book.data.quests: store.claim_quest(quest.id)
		for achievement in book.data.achievements: Expansion.claim(store, achievement.id)
		if stage == 1:
			assert(store.forge("sword_2"))
			assert(store.equip(store.profile.items.back().uid))
		while store.upgrade("hero"): pass
		for id in ["breaker", "barrier", "flow"]:
			if id not in store.profile.expansion.builds.eira.learned: Expansion.talent(store, id)
		if store.profile.assists.lumi < 6: store.upgrade("assist")
		Expansion.rank_up(store)
		print("Cleared %d · level %d · Lumi rank %d" % [stage, store.profile.heroes.eira.level, store.profile.expansion.ranks.lumi])
	assert(store.profile.cleared.size() == 18)
	assert(store.profile.expansion.records.size() == 3)
	assert(store.profile.expansion.ranks.lumi == 3)
	print("PASS: all 18 stages, ten branches and three challenges from a fresh profile using earned resources, reload between runs")
	quit()
