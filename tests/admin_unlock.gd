extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var folder := "user://first_light_tests/admin_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(folder)
	var book := GameCatalog.new()
	var store := ProgressStore.new(book,folder.path_join("save.json"))
	assert(store.valid(store.profile) and not store.profile.has("redeemed_codes"))
	var before := store.profile.duplicate(true)
	assert(not AdminUnlock.redeem(store,"wrong") and store.profile == before)
	store.read_only = true
	assert(not AdminUnlock.redeem(store,"admin") and store.profile == before)
	store.read_only = false
	assert(store.begin_run(1))
	before = store.profile.duplicate(true)
	assert(not AdminUnlock.redeem(store,"admin") and store.profile == before)
	assert(store.settle(store.profile.pending.id,false,0))
	var p := store.profile.duplicate(true)
	p.gold = 5000
	assert(store.commit(p) and Recruitment.summon(store,10))
	before = store.profile.duplicate(true)
	var disk := FileAccess.get_file_as_string(store.path)
	store.fail_writes = true
	assert(not AdminUnlock.redeem(store,"admin"))
	assert(store.profile == before and FileAccess.get_file_as_string(store.path) == disk)
	store.fail_writes = false
	assert(AdminUnlock.redeem(store," AdMiN ") and store.valid(store.profile))
	var unlocked := store.profile.duplicate(true)
	assert(unlocked.redeemed_codes == ["admin"])
	assert(unlocked.hero == before.hero and unlocked.assist == before.assist)
	assert(Formation.state(unlocked,book) == Formation.state(before,book))
	assert(unlocked.recruitment.history == before.recruitment.history)
	for key in ["seed","count","pity"]: assert(unlocked.recruitment[key] == before.recruitment[key])
	assert(unlocked.settled == before.settled and unlocked.claimed == before.claimed)
	for key in ["gold","shards","xp"]: assert(unlocked[key] >= AdminUnlock.RESOURCES)
	for hero in book.data.heroes:
		assert(store.available_hero(hero.id) and unlocked.heroes[hero.id].level == 100)
		assert(unlocked.heroes[hero.id].skills == [10,10,10])
		assert(unlocked.heroes[hero.id].equipment == before.heroes[hero.id].equipment)
		assert(unlocked.recruitment.awakening[hero.id] == 5 and HeroEvolution.rank(unlocked,hero.id) == 3)
		for talent in book.data.talents: assert(talent.id in unlocked.expansion.builds[hero.id].learned)
	for spirit in book.data.assists:
		assert(store.available_assist(spirit.id) and unlocked.assists[spirit.id] == 20)
		assert(unlocked.expansion.spirit_skills[spirit.id].level == 10)
	for stage in book.data.stages: assert(stage.id in unlocked.cleared and store.can_enter(stage.id))
	var gear: Array = unlocked.bag_rewards.duplicate()
	for item in unlocked.items:
		gear.append(item.base)
		assert(item.enhance == EquipmentSystem.MAX_ENHANCE and item.rank == 3)
	for item in before.items:
		var kept := false
		for now in unlocked.items:
			if now.uid == item.uid and now.base == item.base: kept = true
		assert(kept)
	for row in book.data.items: assert(row.id in gear and row.id in unlocked.expansion.discovered)
	assert(unlocked.items.size() <= ProgressStore.BAG_CAP and unlocked.bag_rewards.size() <= 128)
	assert(not store.available_hero("selena_preview"))
	assert(not AdminUnlock.redeem(store,"admin") and store.profile == unlocked)
	var reload := ProgressStore.new(book,store.path)
	assert(reload.profile == unlocked and not AdminUnlock.redeem(reload,"admin"))
	p = unlocked.duplicate(true)
	p.redeemed_codes = ["admin","admin"]
	assert(not store.valid(p))
	var full := ProgressStore.new(book,folder.path_join("full.json"))
	p = full.profile.duplicate(true)
	while p.items.size() < ProgressStore.BAG_CAP: assert(full._add_item(p,"sword_1"))
	while p.bag_rewards.size() < 128: p.bag_rewards.append("sword_1")
	assert(full.commit(p))
	assert(not AdminUnlock.redeem(full,"admin") and full.profile == p)
	print("PASS: atomic admin grant, all runtime content, caps/UID preservation, one-time reload protection, invalid/read-only/pending/full/write-failure rollback")
	quit()
