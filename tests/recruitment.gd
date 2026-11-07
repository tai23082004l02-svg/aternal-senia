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
	var dir := "user://first_light_tests/recruitment_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	var path := dir.path_join("save.json")
	store = ProgressStore.new(book, path)
	check(not Recruitment.summon(store), "Insufficient gold")
	check(not store.available_hero("ryn") and not store.available_assist("ash"), "New entities start locked")
	var p := store.profile.duplicate(true)
	p.gold = 1000000
	p.xp = 100000
	p.shards = 1000
	p.assists.lumi = 6
	p.assists.ash = 6
	p.heroes.eira.skills[2] = 4
	p.heroes.ryn.skills[2] = 6
	p.expansion.builds.eira.learned = ["nova"]
	p.expansion.builds.eira.selected[2] = "nova"
	check(store.commit(p), "Legacy investment fixture")
	var legacy: Dictionary = p.duplicate(true)
	legacy.version = 3
	var legacy_path := dir.path_join("legacy-v3.json")
	var file := FileAccess.open(legacy_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var legacy_bytes := FileAccess.get_file_as_bytes(legacy_path)
	var migrated := ProgressStore.new(book, legacy_path)
	check(not migrated.read_only and migrated.profile.version == 4 and migrated.profile.gold == legacy.gold, "v3 migration keeps wallets")
	check(SpiritSkills.upgrade(migrated) and FileAccess.get_file_as_bytes(legacy_path + ".bak") == legacy_bytes, "First v4 write backs up original v3 bytes")
	check(SpiritSkills.builds(p).lumi.level == 6 and SpiritSkills.builds(p).ash.level == 6, "Both spirits inherit highest paid legacy level")
	check(SpiritSkills.builds(p).lumi.selected == "nova", "Legacy branch retained")
	store.fail_writes = true
	check(not Recruitment.summon(store) and not SpiritSkills.upgrade(store), "Failed writes rejected")
	check(store.profile == p and ProgressStore.new(book, path).profile == p, "No RAM or disk deduction on failure")
	store.fail_writes = false
	check(SpiritSkills.choose(store, "echo"), "Legacy selected branch satisfies advanced prerequisite")
	check(SpiritSkills.upgrade(store), "Independent active spirit skill upgrade")
	check(book.stats(store.profile).skills[2] == 7 and store.profile.heroes.eira.skills[2] == 4, "New spirit level independent of hero legacy field")
	check(SpiritSkills.builds(store.profile).ash.level == 6, "Other spirit unaffected")
	check(SpiritSkills.choose(store, "nova"), "Deselect base branch")
	check(SpiritSkills.builds(store.profile).lumi.advanced == "", "Removing parent deselects advanced effect")
	check(not SpiritSkills.choose(store, "aegis"), "Advanced branch requires parent")
	check(SpiritSkills.choose(store, "flow") and SpiritSkills.choose(store, "aegis"), "Choose alternate base and advanced branch")
	check(book.stats(store.profile).variants[2] == "flow" and book.stats(store.profile).spirit_advanced == "aegis", "Spirit tree captured in stats")
	var battle := BattleModel.new(book)
	battle.start({"id": "aegis", "stage": 1, "seed": 7, "stats": book.stats(store.profile)})
	battle.wave = 2
	battle._spawn()
	battle.auto_attack = false
	check(battle.skill(2), "Spirit skill command")
	for i in range(35): battle.advance(BattleModel.STEP)
	check(is_equal_approx(battle.barrier, battle.stats.hp * .1), "Aegis creates actual barrier at marker")
	for tier in [1, 2, 3]:
		check(not Recruitment.pool(book, tier).is_empty(), "Every rarity has candidates")
	check(Recruitment.rarity("item", "armor_4", book) == 3 and not store.forge("armor_4"), "Epic armor is classified and summon-only")
	p = store.profile.duplicate(true)
	p.recruitment = Recruitment.fresh()
	p.recruitment.seed = 17
	p.recruitment.pity = 19
	check(store.commit(p), "Pity fixture")
	var gold: int = store.profile.gold
	check(Recruitment.summon(store), "Guaranteed epic draw")
	check(store.profile.recruitment.history[0].rarity == 3 and store.profile.recruitment.pity == 0, "Pity guarantees and resets")
	check(store.profile.gold == gold - 120, "Exactly one summon cost")
	var categories := {}
	for i in range(200):
		check(Recruitment.summon(store), "Funded deterministic draw %d" % i)
		var reward: Dictionary = store.profile.recruitment.history[0]
		categories[reward.kind] = true
		check(store.profile.recruitment.pity <= 19 and store.profile.recruitment.history.size() <= 10, "Bounded pity and history")
	check(categories.size() == 3, "Fixed seed covers all three reward categories")
	check(store.available_hero("ryn") and store.available_hero("mira") and store.available_assist("ash"), "Summoned entities unlock before chapter clear")
	check(store.profile.recruitment.fragments.ryn > 0 and store.profile.expansion.cores > 0, "Duplicate heroes and spirits convert to materials")
	check(store.profile.items.size() == ProgressStore.BAG_CAP, "Equipment overflow capped at 40")
	check(store.profile.shards > 1000, "Overflow converted to shards")
	var saved := store.profile.duplicate(true)
	store = ProgressStore.new(book, path)
	check(store.profile == saved and not store.read_only, "Recruitment and trees survive restart")
	check(store.begin_run(1), "Begin with new tree snapshot")
	var snapshot: Dictionary = store.profile.pending.duplicate(true)
	check(not Recruitment.summon(store) and not Recruitment.awaken(store) and not Recruitment.level_batch(store) and not SpiritSkills.choose(store, "echo"), "Pending run locks all build and summon changes")
	check(ProgressStore.new(book, path).profile.pending == snapshot, "Snapshot reload unchanged")
	check(store.settle(snapshot.id, false, 0), "Abandon run")
	p = store.profile.duplicate(true)
	p.heroes.eira.level = 20
	p.recruitment.fragments.eira = 100
	check(store.commit(p), "Awakening fixture")
	var stats := book.stats(store.profile)
	store.fail_writes = true
	check(not Recruitment.awaken(store) and book.stats(store.profile) == stats, "Failed awakening preserves stats")
	store.fail_writes = false
	check(Recruitment.awaken(store) and Recruitment.awaken(store), "Two awakening ranks")
	check(not Recruitment.awaken(store), "Awakening cap")
	var awakened := book.stats(store.profile)
	check(awakened.hp == stats.hp + 60 and awakened.atk == stats.atk + 6 and awakened.defense == stats.defense + 2, "Actual awakening stat bonuses")
	check(Recruitment.level_batch(store) and store.profile.heroes.eira.level == 25, "Atomic five-level upgrade")
	p = store.profile.duplicate(true)
	p.gold = 0
	check(store.commit(p), "Empty wallet fixture")
	var before := store.profile.duplicate(true)
	check(not Recruitment.level_batch(store) and store.profile == before, "Batch upgrade cannot partially spend")
	for invalid in ["bad", -1, 20]:
		p = before.duplicate(true)
		p.recruitment.pity = invalid
		check(not store.valid(p), "Invalid pity rejected")
	p = before.duplicate(true)
	p.expansion.spirit_skills.lumi.advanced = "unknown"
	check(not store.valid(p), "Unknown spirit branch rejected")
	p = before.duplicate(true)
	p.recruitment.history[0].rarity = 99
	check(not store.valid(p), "False rarity history rejected")
	print("%s: %d recruitment, character upgrade and separate spirit tree checks" % ["FAIL" if failed else "PASS", checks])
	quit(1 if failed else 0)
