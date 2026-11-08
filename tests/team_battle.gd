extends SceneTree
var book := GameCatalog.new()
func _initialize() -> void: call_deferred("run")
func fixture(path: String) -> ProgressStore:
	var store := ProgressStore.new(book, path)
	var p := store.profile.duplicate(true)
	p.cleared = [1, 2]
	p.gold = 10000
	p.shards = 100
	p.formation = {"slots":["ryn","mira","eira"], "auto_ult":true, "auto_next":true}
	p.hero = "ryn"
	p.assist = "ash"
	assert(store.commit(p))
	return store
func run() -> void:
	var dir := "user://first_light_tests/team_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	var store := fixture(dir.path_join("save.json"))
	# v12 three-slot formations expand without changing RAM or file bytes.
	var old_profile := store.profile.duplicate(true)
	var formation_bytes := FileAccess.get_file_as_bytes(store.path)
	assert(Formation.state(store.profile, book).slots == ["ryn","mira","eira",""])
	assert(store.profile == old_profile and FileAccess.get_file_as_bytes(store.path) == formation_bytes)
	var four := fixture(dir.path_join("four.json"))
	assert(not Formation.assign(four, 3, "lyra")) # Still locked.
	var unlocked := four.profile.duplicate(true)
	unlocked.cleared = [1,2,3,4,5]
	assert(four.commit(unlocked))
	four.fail_writes = true
	var before_four := four.profile.duplicate(true)
	assert(not Formation.assign(four, 3, "lyra") and four.profile == before_four)
	four.fail_writes = false
	assert(Formation.assign(four, 3, "lyra"))
	assert(Formation.assign(four, 0, "lyra"))
	assert(four.profile.formation.slots == ["lyra","mira","eira","ryn"])
	assert(not Formation.assign(four, 4, "eira"))
	assert(four.begin_run(1))
	var four_run: Dictionary = four.profile.pending.duplicate(true)
	assert(four_run.team.version == 3 and four_run.team.units.size() == 4)
	assert(not Formation.assign(four, 3, ""))
	var reloaded := ProgressStore.new(book, four.path)
	assert(not reloaded.read_only and reloaded.profile.pending == four_run)
	var four_model := TeamBattle.new(book)
	var fast_model := TeamBattle.new(book)
	four_model.start(four_run)
	fast_model.start(four_run)
	assert(four_model._front() == 0)
	four_model.allies[0].hp = 0
	assert(four_model._front() == 1)
	four_model.start(four_run)
	fast_model.speed = 2
	for i in range(12000):
		four_model.advance(1.0 / 60)
		fast_model.advance(1.0 / 120)
		if four_model.state != "battle": break
	assert(four_model.state == "won" and fast_model.state == four_model.state)
	assert(four_model.hp == fast_model.hp and four_model.kills == fast_model.kills)
	assert(four.settle(four_run.id, true, four_model.kills, four_model.time))
	var rewarded := four.profile.duplicate(true)
	assert(four.settle(four_run.id, true, four_model.kills, four_model.time))
	assert(four.profile == rewarded)
	# Real v1 three-unit pending remains unchanged through reload and resume.
	var legacy_team := fixture(dir.path_join("legacy_team.json"))
	assert(legacy_team.begin_run(1))
	var old_pending := legacy_team.profile.duplicate(true)
	old_pending.pending.team.version = 1
	assert(legacy_team.commit(old_pending))
	var resumed := ProgressStore.new(book, legacy_team.path)
	assert(not resumed.read_only and resumed.profile.pending == old_pending.pending)
	four_model.start(resumed.profile.pending)
	assert(four_model.allies.size() == 3)
	var invalid_team: Dictionary = four_run.team.duplicate(true)
	invalid_team.version = 1
	assert(not Formation.valid_snapshot(four, invalid_team))
	var saved := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not Formation.assign(store, 1, "eira") and store.profile == saved)
	store.fail_writes = false
	assert(Formation.assign(store, 1, "eira"))
	assert(store.profile.formation.slots == ["ryn","eira","mira",""])
	assert(Formation.assign(store, 1, "mira"))
	assert(store.begin_run(1))
	var pending: Dictionary = store.profile.pending.duplicate(true)
	assert(pending.team.units.size() == 3)
	assert(not Formation.assign(store, 0, "eira"))
	assert(not store.upgrade("hero"))
	assert(ProgressStore.new(book, store.path).profile.pending == pending)
	var first := TeamBattle.new(book)
	var second := TeamBattle.new(book)
	first.start(pending)
	second.start(pending)
	assert(first.allies.size() == 3 and first.enemies.size() == 1)
	for i in range(12000):
		first.advance(1.0 / 60)
		second.advance(1.0 / 60)
		assert(first.enemies.filter(func(e): return e.hp > 0).size() <= 4)
		if first.state != "battle": break
	assert(first.state == "won", "Three starter-level owned heroes must clear opening encounter")
	assert(first.kills == 4)
	assert(first.state == second.state and first.hp == second.hp and first.events == second.events)
	var fast := TeamBattle.new(book)
	fast.start(pending)
	fast.speed = 2
	for i in range(12000):
		fast.advance(1.0 / 60)
		if fast.state != "battle": break
	assert(fast.state == first.state and fast.hp == first.hp and fast.time == first.time)
	for definition in book.data.stages:
		assert(Formation.valid_snapshot(store, Formation.snapshot(book, saved, definition)))
	assert(store.settle(pending.id, true, first.kills, first.time))
	var gold: int = store.profile.gold
	assert(store.settle(pending.id, true, first.kills, first.time) and store.profile.gold == gold)
	# Dead front unit does not end battle; enemies retarget the next survivor.
	var model := TeamBattle.new(book)
	model.start(pending)
	model._damage_ally(0, 1e6, 0)
	assert(model.state == "battle" and model._front() == 1)
	model._damage_ally(1, 1e6, 0)
	model._damage_ally(2, 1e6, 0)
	assert(model.state == "lost")
	model.start(pending)
	model.time = 179.99
	model.advance(.1)
	assert(model.state == "lost" and model.defeat_reason == "Time expired")
	# Ultimate gating, pause and speed, marker damage and no early damage.
	model.start(pending)
	model.auto_ultimate = false
	model.allies[0].energy = 100
	assert(model.ultimate(0))
	var before: float = model.enemies[0].hp
	model.advance(.2)
	assert(model.enemies[0].hp == before)
	model.paused = true
	var time := model.time
	model.advance(.25)
	assert(model.time == time)
	model.paused = false
	model.advance(.25)
	model.advance(.1)
	assert(model.enemies[0].hp < before)
	# Boss reinforcement happens once and stays bounded; focus rejects dead targets.
	var boss_pending := pending.duplicate(true)
	boss_pending.stage = 2
	boss_pending.team.encounter = Formation.encounter(book.find_row("stages", 2))
	model.start(boss_pending)
	model.wave = model.wave_count() - 1
	model._spawn()
	model.enemies[0].hp = model.enemies[0].max_hp * .49
	model.advance(.1)
	assert(model.enemies.size() == 3 and model.enemies[0].summoned)
	model._add_enemy({"type":"slime", "name":"Cap test", "hp":20,"atk":4,"boss":false,"elite":false,"mechanic":"smash","element":"nature"})
	assert(model.enemies.size() == 4)
	model.enemies[3].hp = 0
	model._add_enemy({"type":"slime", "name":"Replacement", "hp":20,"atk":4,"boss":false,"elite":false,"mechanic":"smash","element":"nature"})
	assert(model.enemies.size() == 4 and model.enemies[3].name == "Replacement")
	assert(model.select_target(2))
	model.enemies[2].hp = 0
	assert(not model.select_target(2) and model._target() != 2)
	# A spirit ultimate that ends the battle cancels its own remaining action safely.
	model.start(pending)
	model.wave = model.wave_count() - 1
	model._spawn()
	model.enemies[0].hp = 1
	for ally in model.allies: ally.clock = -10
	model.assist_clock = -10
	model.spirit_energy = 100
	assert(model.spirit_ultimate())
	for i in range(40): model.advance(1.0 / 60)
	assert(model.state == "won" and model.spirit_action.is_empty())
	# Spirit supports all living allies, never revives defeated units.
	var lumi := pending.duplicate(true)
	lumi.team.assist = "lumi"
	for row in lumi.team.units: row.stats.assist = "lumi"
	model.start(lumi)
	for ally in model.allies: ally.hp *= .5
	model.allies[2].hp = 0
	model._spirit(false)
	assert(model.allies[0].hp > model.allies[0].stats.hp * .5 and model.allies[1].hp > model.allies[1].stats.hp * .5 and model.allies[2].hp == 0)
	# Legacy v6 pending retains its exact singleton snapshot; no implicit new team.
	var legacy := saved.duplicate(true)
	legacy.version = 6
	legacy.erase("formation")
	legacy.pending = {"id":"legacy", "stage":1, "seed":17, "stats":book.stats(legacy)}
	var file := FileAccess.open(dir.path_join("legacy.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var migrated := ProgressStore.new(book, dir.path_join("legacy.json"))
	assert(not migrated.read_only and migrated.profile.version == ProgressStore.VERSION and not migrated.profile.pending.has("team"))
	assert(migrated.profile.pending == legacy.pending)
	# Public v7 unique-collection saves migrate without changing the frozen legacy run.
	legacy.version = 7
	for id in legacy.collection_fragments.items.keys():
		if id not in EquipmentSystem.OLD_ITEMS: legacy.collection_fragments.items.erase(id)
	var v7_path := dir.path_join("legacy-v7.json")
	file = FileAccess.open(v7_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var old_bytes := FileAccess.get_file_as_bytes(v7_path)
	var v7 := ProgressStore.new(book, v7_path)
	assert(not v7.read_only and v7.profile.pending == legacy.pending)
	for id in EquipmentSystem.OLD_ITEMS: assert(v7.profile.collection_fragments.items[id] == legacy.collection_fragments.items[id])
	for id in v7.profile.collection_fragments.items:
		if id not in EquipmentSystem.OLD_ITEMS: assert(v7.profile.collection_fragments.items[id] == 0)
	assert(v7.setting("sound", false))
	assert(FileAccess.get_file_as_bytes(v7_path + ".bak") == old_bytes)
	# New one-hero profile can still enter, without granting unowned heroes.
	var fresh := ProgressStore.new(book, dir.path_join("fresh.json"))
	assert(not fresh.available_hero("ryn"))
	assert(fresh.begin_run(1) and fresh.profile.pending.team.units.size() == 1)
	model.start(fresh.profile.pending)
	for i in range(12000):
		model.advance(1.0 / 60)
		if model.state != "battle": break
	assert(model.state == "won", "Fresh Eira profile must clear first stage")
	print("PASS: formation/owned/swap/write failure, 4vN and legacy 3vN targets/markers/spirits/timeout/boss adds, deterministic results, opening balance, legacy pending")
	quit()
