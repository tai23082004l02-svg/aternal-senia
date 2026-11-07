extends SceneTree

var checks := 0
var failed := false

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failed = true
		push_error("FAIL: " + label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var book := GameCatalog.new()
	var path := "user://first_light_tests/hero_management_%d.json" % Time.get_ticks_usec()
	var store := ProgressStore.new(book, path)
	check(not HeroEvolution.eligible(store, "unknown") and not HeroEvolution.evolve(store, "ryn"), "Unknown/locked hero rejected")
	check(not store.upgrade("hero", 0, "ryn") and not Recruitment.awaken(store, "ryn"), "Locked target upgrade rejected")
	check(HeroEvolution.rank(store.profile, "eira") == 1 and not store.profile.has("evolution"), "Old save defaults without mutation")
	var p := store.profile.duplicate(true)
	p.gold = 100000
	p.xp = 100000
	p.shards = 100
	p.cleared = [1, 2]
	p.expansion.cores = 50
	p.heroes.ryn.level = 14
	p.recruitment = Recruitment.fresh()
	p.recruitment.fragments.ryn = 100
	store._add_item(p, "armor_4")
	check(store.commit(p), "Targeted fixture committed")
	check(store.profile.hero == "eira", "Eira remains deployed")
	check(store.upgrade("hero", 0, "ryn") and store.profile.heroes.ryn.level == 15, "Upgrade inspected hero")
	check(store.profile.hero == "eira" and store.profile.heroes.eira.level == 1, "Target upgrade never switches or levels active hero")
	check(Recruitment.awaken(store, "ryn") and store.profile.recruitment.awakening.ryn == 2, "Fragments raise selected hero star count")
	check(not store.profile.has("evolution"), "Star expansion is separate from evolution")
	check(store.equip("item_1", "ryn"), "Equip inspected hero without deployment change")
	check(store.profile.hero == "eira" and store.profile.heroes.ryn.equipment.armor == "item_1", "Gear ownership targeted")
	check(not store.equip("item_1", "eira"), "UID cannot be owned twice")
	check(not store.equip("starter_eira", "ryn"), "Class restrictions preserved")
	var stats := book.stats(store.profile, "ryn")
	var before := store.profile.duplicate(true)
	store.fail_writes = true
	check(not HeroEvolution.evolve(store, "ryn") and store.profile == before, "Failed evolution keeps all wallets, stars and stats")
	store.fail_writes = false
	check(HeroEvolution.evolve(store, "ryn"), "Evolution tier two")
	check(store.profile.hero == "eira" and HeroEvolution.rank(store.profile, "ryn") == 2 and HeroEvolution.rank(store.profile, "eira") == 1, "Evolution independent per hero")
	var evolved := book.stats(store.profile, "ryn")
	check(is_equal_approx(evolved.hp, stats.hp * 1.08) and is_equal_approx(evolved.atk, stats.atk * 1.08) and is_equal_approx(evolved.defense, stats.defense * 1.08), "Evolution changes actual derived stats")
	check(store.profile.gold == before.gold - 250 and store.profile.shards == before.shards - 10 and store.profile.expansion.cores == before.expansion.cores - 3, "Evolution exact atomic costs")
	check(store.profile.recruitment.fragments == before.recruitment.fragments and store.profile.recruitment.awakening == before.recruitment.awakening, "Evolution never spends fragments or alters stars")
	check(not HeroEvolution.evolve(store, "ryn"), "Higher tier level/star gate")
	check(store.unequip("item_1", "ryn") and store.profile.hero == "eira", "Target unequip preserves active hero")
	check(Recruitment.level_batch(store, 5, "ryn") and store.profile.heroes.ryn.level == 20, "Five levels on selected hero")
	check(Recruitment.awaken(store, "ryn"), "Raise selected hero to three stars")
	p = store.profile.duplicate(true)
	p.heroes.ryn.level = 30
	check(store.commit(p) and HeroEvolution.evolve(store, "ryn"), "Evolution tier three")
	check(not HeroEvolution.evolve(store, "ryn"), "Evolution cap")
	var saved := store.profile.duplicate(true)
	var reloaded := ProgressStore.new(book, path)
	check(reloaded.profile == saved and not reloaded.read_only, "Evolution persists exactly")
	check(store.change_hero("ryn") and store.begin_run(1), "Evolved hero enters real battle")
	var snapshot: Dictionary = store.profile.pending.duplicate(true)
	check(snapshot.stats == book.stats(store.profile), "Battle snapshot includes evolution bonuses")
	before = store.profile.duplicate(true)
	check(not HeroEvolution.evolve(store, "eira") and not store.upgrade("hero", 0, "eira") and not store.equip("item_1", "eira"), "Pending run blocks targeted actions")
	check(store.profile == before and ProgressStore.new(book, path).profile.pending == snapshot, "Pending snapshot and profile unchanged")
	p = saved.duplicate(true)
	p.evolution.ryn = 4
	check(not store.valid(p), "Out-of-range evolution rejected")
	p = saved.duplicate(true)
	p.evolution.erase("mira")
	check(not store.valid(p), "Incomplete evolution rejected")
	p = saved.duplicate(true)
	p.evolution = []
	check(not store.valid(p), "Invalid evolution type rejected")
	print("%s: %d hero management checks" % ["FAIL" if failed else "PASS", checks])
	quit(1 if failed else 0)
