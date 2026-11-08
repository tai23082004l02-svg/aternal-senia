extends SceneTree

func _initialize() -> void:
	var book := GameCatalog.new()
	assert(book.errors.is_empty())
	var path := "user://first_light_tests/contracts_%d/save.json" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var store := ProgressStore.new(book,path)
	var old := store.profile.duplicate(true)
	old.gold = 5000
	old.cleared = [1,2,3,4,5]
	assert(store.commit(old))
	var old_reload := ProgressStore.new(book,path)
	assert(not old_reload.read_only and old_reload.profile == old)
	assert(store.begin_run(1))
	var modern: Dictionary = store.profile.pending.duplicate(true)
	var legacy := modern.duplicate(true)
	for unit in legacy.team.units: unit.stats.erase("combat")
	assert(Formation.valid_snapshot(store, legacy.team))
	var invalid := modern.duplicate(true)
	invalid.team.units[0].stats.combat.damage_taken = -1
	assert(not Formation.valid_snapshot(store,invalid.team))
	var first := TeamBattle.new(book)
	first.catalog = book
	first.start(modern)
	var second := TeamBattle.new(book)
	second.catalog = book
	second.start(legacy)
	for tick in range(1800):
		first.advance(1.0/30)
		second.advance(1.0/30)
		assert(first.state == second.state and first.rng.state == second.rng.state)
		for i in range(first.allies.size()): assert(first.allies[i].hp == second.allies[i].hp)
		for i in range(first.enemies.size()): assert(first.enemies[i].hp == second.enemies[i].hp)
		if first.state != "battle": break
	assert(store.settle(store.profile.pending.id,false,0))
	assert(Recruitment.summon(store,10))
	var committed := store.profile.duplicate(true)
	assert(committed.recruitment.last_batch.entries.size() == 10)
	var reload := ProgressStore.new(book,path)
	assert(not reload.read_only and reload.profile == committed)
	var bad := committed.duplicate(true)
	bad.recruitment.last_batch.entries[0].id = "unknown"
	assert(not store.commit(bad) and store.profile == committed)
	var malformed: Dictionary = book.data.heroes[0].duplicate(true)
	malformed.weapon_category = "gun"
	assert(not HeroContract.valid(malformed))
	print("PASS: v12 roundtrip, frozen pending compatibility, seeded combat equivalence, durable batch and invalid contract guards")
	quit()
