extends SceneTree

var checks := 0
var failed := false
var book := GameCatalog.new()
var store: ProgressStore

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failed = true
		push_error("FAIL: " + label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var dir := "user://first_light_tests/training_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	var path := dir.path_join("save.json")
	store = ProgressStore.new(book, path)
	check(store.valid(store.profile), "Legacy profile without training remains valid")
	var base := book.stats(store.profile)
	check(AttributeTraining.remaining(store.profile, "eira") == 0, "Level one has no points")
	check(not AttributeTraining.change(store, "atk", 1), "Cannot overspend")
	check(not AttributeTraining.change(store, "hp", -1), "Cannot refund unallocated points")
	check(not AttributeTraining.change(store, "crit", 1), "Unknown attribute rejected")
	check(not AttributeTraining.change(store, "hp", 2), "Only unit increments")
	check(not AttributeTraining.reset(store), "Empty reset rejected")
	var p := store.profile.duplicate(true)
	p.heroes.eira.level = 4
	p.heroes.ryn.level = 3
	p.cleared = [1, 2]
	p.gold = 1000
	p.xp = 1000
	check(store.commit(p), "Fixture saved with no training field")
	var old_profile := store.profile.duplicate(true)
	var original_stats := book.stats(old_profile)
	store = ProgressStore.new(book, path)
	check(not store.read_only and store.profile == old_profile, "Old v3 reload unchanged")
	check(AttributeTraining.remaining(store.profile, "eira") == 6, "Retroactive level points")
	store.fail_writes = true
	check(not AttributeTraining.change(store, "hp", 1), "Write failure rejects allocation")
	check(store.profile == old_profile, "Write failure preserves RAM and wallet")
	check(ProgressStore.new(book, path).profile == old_profile, "Write failure preserves disk")
	store.fail_writes = false
	check(AttributeTraining.change(store, "hp", 1), "Allocate HP")
	var backup = JSON.parse_string(FileAccess.get_file_as_string(path + ".bak"))
	check(not backup.has("training"), "First write backs up untouched old save")
	check(AttributeTraining.change(store, "atk", 1), "Allocate attack")
	check(AttributeTraining.change(store, "defense", 1), "Allocate defense")
	var trained := book.stats(store.profile)
	check(trained.hp == original_stats.hp + 10, "HP adds ten per point")
	check(trained.atk == original_stats.atk + 1.5, "Attack preserves fractional bonus")
	check(trained.defense == original_stats.defense + .75, "Defense preserves fractional bonus")
	var original_battle := BattleModel.new(book)
	var trained_battle := BattleModel.new(book)
	for pair in [[original_battle, original_stats], [trained_battle, trained]]:
		var stats: Dictionary = pair[1].duplicate(true)
		stats.crit = 0
		pair[0].start({"id": "training_combat", "stage": 1, "seed": 7, "stats": stats})
		pair[0].auto_attack = false
		for i in range(24): pair[0].advance(1.0 / 60)
		check(pair[0].attack(), "Normal model attack accepted")
		for i in range(9): pair[0].advance(1.0 / 60)
		check(pair[0].enemy_hp == pair[0].enemy_max, "Training cannot move hit before marker")
		for i in range(6): pair[0].advance(1.0 / 60)
	check(trained_battle.enemy_hp < original_battle.enemy_hp, "Allocated ATK increases actual marker damage")
	for i in range(150):
		original_battle.advance(1.0 / 60)
		trained_battle.advance(1.0 / 60)
	check(trained_battle.stats.hp - trained_battle.hp < original_battle.stats.hp - original_battle.hp, "Allocated defense reduces actual enemy damage")
	check(store.profile.gold == old_profile.gold and store.profile.xp == old_profile.xp, "Training never charges wallet")
	check(AttributeTraining.remaining(store.profile, "eira") == 3, "Spent points subtracted")
	store = ProgressStore.new(book, path)
	check(book.stats(store.profile) == trained, "Training persists exactly")
	check(AttributeTraining.allocation(store.profile, "ryn").atk == 0, "Allocations isolated by hero")
	check(store.change_hero("ryn"), "Select unlocked second hero")
	check(AttributeTraining.remaining(store.profile, "ryn") == 4, "Second hero owns level points")
	check(AttributeTraining.change(store, "atk", 1), "Train second hero")
	check(AttributeTraining.allocation(store.profile, "eira").atk == 1, "First hero unaffected")
	check(store.change_hero("eira"), "Return to first hero")
	for i in range(3):
		check(AttributeTraining.change(store, "hp", 1), "Spend remaining point %d" % i)
	check(not AttributeTraining.change(store, "hp", 1), "Exact budget cap")
	check(AttributeTraining.change(store, "hp", -1), "Individual point refund")
	check(store.begin_run(1), "Snapshot includes trained stats")
	var snapshot: Dictionary = store.profile.pending.duplicate(true)
	var battle := BattleModel.new(book)
	battle.start(snapshot)
	check(battle.hp == book.stats(store.profile).hp and battle.stats.atk == book.stats(store.profile).atk, "Battle consumes trained HP/attack")
	check(not AttributeTraining.change(store, "atk", 1) and not AttributeTraining.reset(store), "Pending run locks allocation and reset")
	store = ProgressStore.new(book, path)
	check(store.profile.pending == snapshot, "Pending snapshot survives restart unchanged")
	check(store.settle(snapshot.id, false, 0), "Abandon without rewards")
	store.fail_writes = true
	var before_reset := store.profile.duplicate(true)
	check(not AttributeTraining.reset(store) and store.profile == before_reset, "Failed reset preserves allocation")
	store.fail_writes = false
	check(AttributeTraining.reset(store), "Free full refund")
	check(book.stats(store.profile) == original_stats and AttributeTraining.remaining(store.profile, "eira") == 6, "Reset restores base stats and points")
	check(AttributeTraining.allocation(store.profile, "ryn").atk == 1, "Reset isolated by hero")
	check(store.upgrade("hero"), "Normal level upgrade")
	check(AttributeTraining.remaining(store.profile, "eira") == 8, "Next level awards two points once")
	for bad in [-1, .5, 199, "2"]:
		p = store.profile.duplicate(true)
		p.training.eira.atk = bad
		check(not store.valid(p), "Reject invalid points: " + str(bad))
	p = store.profile.duplicate(true)
	p.training.eira.atk = 9
	check(not store.valid(p), "Reject total above hero budget")
	p = store.profile.duplicate(true)
	p.training.eira["crit"] = 0
	check(not store.valid(p), "Reject extra attribute")
	p = store.profile.duplicate(true)
	p.training.erase("ryn")
	check(not store.valid(p), "Reject partial training data")
	p = store.profile.duplicate(true)
	p.training = []
	check(not store.valid(p), "Reject malformed training data")
	p = store.profile.duplicate(true)
	p.heroes.eira.level = 100
	p.training.eira.atk = 198
	check(store.valid(p) and AttributeTraining.remaining(p, "eira") == 0, "Level 100 budget valid")
	store.read_only = true
	check(not AttributeTraining.change(store, "atk", 1) and not AttributeTraining.reset(store), "Read-only profile protected")
	check(base.hp > 0, "Starter stats unaffected")
	print("%s: %d attribute training checks" % ["FAIL" if failed else "PASS", checks])
	quit(1 if failed else 0)
