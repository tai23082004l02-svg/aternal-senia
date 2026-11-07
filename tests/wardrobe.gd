extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var book := GameCatalog.new()
	var path := "user://first_light_tests/wardrobe_%d.json" % Time.get_ticks_usec()
	var store := ProgressStore.new(book, path)
	assert(Wardrobe.selected(store.profile, "eira") == "original" and not store.profile.has("outfits"))
	assert(not Wardrobe.apply(store, "ryn", "moon") and not Wardrobe.apply(store, "eira", "unknown"))
	var p := store.profile.duplicate(true)
	p.cleared = [1, 2]
	p.gold = 10000
	p.shards = 100
	p.heroes.ryn.level = 4
	assert(store.commit(p))
	var original := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not Wardrobe.apply(store, "ryn", "moon") and store.profile == original)
	store.fail_writes = false
	var base := book.stats(store.profile, "ryn")
	assert(Wardrobe.apply(store, "ryn", "moon"))
	var changed := book.stats(store.profile, "ryn")
	for stat in ["hp", "atk", "defense", "crit", "skills", "variants"]: assert(changed[stat] == base[stat])
	assert(changed.look_tint != base.look_tint and store.profile.gold == original.gold)
	assert(Wardrobe.selected(store.profile, "eira") == "original" and store.profile.hero == "eira")
	assert(ProgressStore.new(book, path).profile == store.profile)
	assert(Expansion.talent(store, "focus", "ryn") and store.profile.expansion.builds.ryn.selected[0] == "focus")
	assert(store.profile.expansion.builds.eira.selected[0] == "" and store.profile.hero == "eira")
	assert(store.change_hero("ryn") and store.begin_run(1))
	var snapshot: Dictionary = store.profile.pending.duplicate(true)
	assert(snapshot.stats.look_tint == changed.look_tint)
	assert(not Wardrobe.apply(store, "ryn", "dawn") and not Expansion.talent(store, "breaker", "ryn"))
	assert(ProgressStore.new(book, path).profile.pending == snapshot)
	p = store.profile.duplicate(true)
	p.outfits.ryn = "invalid"
	assert(not store.valid(p))
	p = store.profile.duplicate(true)
	p.pending.stats.look_tint = [1, 2, 3]
	assert(not store.valid(p))
	print("PASS: wardrobe defaults, preview metadata, stat neutrality, targeted skill tree, atomic write/reload, snapshot and build lock")
	quit()
