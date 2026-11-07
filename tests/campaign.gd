extends SceneTree

const Catalog = preload("res://game/core/catalog.gd")
const Store = preload("res://game/core/progress.gd")
const Battle = preload("res://game/core/battle.gd")

func _initialize() -> void:
	var book := Catalog.new()
	DirAccess.make_dir_recursive_absolute("user://first_light_tests")
	var save_path := "user://first_light_tests/campaign_%d.json" % Time.get_ticks_usec()
	var store := Store.new(book, save_path)
	for stage in range(1, 6):
		assert(store.begin_run(stage))
		# Resume uses the persisted snapshot, not current UI/catalog stats.
		store = Store.new(book, save_path)
		var battle := Battle.new(book)
		battle.start(store.profile.pending)
		for tick in range(36000):
			if battle.enemy_clock > 2.45:
				battle.guard()
			if battle.hp < battle.stats.hp * .65:
				battle.skill(1)
			elif not battle.warning().begins_with("PHẢN"):
				battle.skill(2)
				battle.skill(0)
			battle.advance(1.0 / 60)
			if battle.state != "battle":
				break
		assert(battle.state == "won", "Fresh progression stage %d" % stage)
		assert(store.settle(battle.run.id, true, battle.kills))
		for quest in book.data.quests:
			store.claim_quest(quest.id)
		if stage == 1:
			assert(store.forge("sword_2"))
			assert(store.equip(store.profile.items.back().uid))
		while store.upgrade("hero"):
			pass
		print("Cleared stage %d · level %d · %d gold / %d XP" % [stage, store.profile.heroes.eira.level, store.profile.gold, store.profile.xp])
	assert(store.profile.cleared.size() == 5)
	assert(store.profile.metrics.wins == 5)
	var final := Store.new(book, save_path)
	assert(final.profile == store.profile)
	print("PASS: fresh profile completes all five stages using only earned rewards, reloads between runs")
	quit()
