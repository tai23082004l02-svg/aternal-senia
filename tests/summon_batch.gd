extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var book := GameCatalog.new()
	var dir := "user://first_light_tests/batch_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	var batch := ProgressStore.new(book, dir.path_join("batch.json"))
	var single := ProgressStore.new(book, dir.path_join("single.json"))
	var p := batch.profile.duplicate(true)
	p.gold = 10000
	p.recruitment = Recruitment.fresh()
	p.recruitment.pity = 19
	p.recruitment.banner_pity = {"premium": 7, "event": 13}
	assert(batch.commit(p) and single.commit(p))
	batch.fail_writes = true
	assert(not Recruitment.summon(batch, 10) and batch.profile == p)
	assert(ProgressStore.new(book, batch.path).profile == p)
	batch.fail_writes = false
	assert(not Recruitment.summon(batch, 18) and batch.profile == p)
	assert(Recruitment.summon(batch, 10))
	for i in range(10): assert(Recruitment.summon(single))
	assert(batch.profile == single.profile, "Batch must exactly match ten sequential rewards, duplicates, overflow, RNG and pity")
	assert(batch.profile.gold == 8800 and batch.profile.recruitment.history.size() == 10)
	assert(Recruitment.banner_pity(batch.profile, "premium") == 7)
	assert(Recruitment.banner_pity(batch.profile, "event") == 13)
	assert(ProgressStore.new(book, batch.path).profile == batch.profile)
	var poor := batch.profile.duplicate(true)
	poor.gold = 1199
	assert(batch.commit(poor))
	assert(not Recruitment.summon(batch, 10) and batch.profile == poor)
	print("PASS: atomic x10 equals ten singles; rollback, funds, reload, independent reserved banner counters")
	quit()
