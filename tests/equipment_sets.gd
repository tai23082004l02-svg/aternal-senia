extends SceneTree
var book := GameCatalog.new()
var directory := "user://first_light_tests/equipment_%d" % Time.get_ticks_usec()

func write(path: String, p: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(p, "", true, true))
	file.close()

func wear(store: ProgressStore, p: Dictionary, id: String, hero: String = "eira") -> void:
	var item := {}
	for candidate in p.items:
		if candidate.base == id: item = candidate
	if item.is_empty():
		store._add_item(p, id)
		item = p.items.back()
	p.heroes[hero].equipment[book.find_row("items", id).slot] = item.uid

func battle(stats: Dictionary) -> BattleModel:
	var model := BattleModel.new(book)
	model.start({"id":"fixture", "seed":19, "stage":1, "stats":stats})
	model.auto_attack = false
	model.enemy_hp = 100000
	model.enemy_max = 100000
	return model

func ticks(model: BattleModel, count: int) -> void:
	for i in range(count): model.advance(BattleModel.STEP)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var store := ProgressStore.new(book, directory.path_join("save.json"))
	assert(book.errors.is_empty() and store.valid(store.profile))
	assert(book.data.items.size() == 26 and book.data.sets.size() == 3)
	var p := store.profile.duplicate(true)
	p.gold = 100000
	p.shards = 1000
	p.cleared = [1,2,3]
	for id in ["sword_dawn", "armor_5", "boots_5", "accessory_5"]: wear(store, p, id)
	assert(store.commit(p))
	var full := book.stats(p)
	assert(full.equipment_sets.dawn == 4 and is_equal_approx(full.hp, (210+115+20+90)*1.08))
	assert(is_equal_approx(full.skill_bonus, 1.12*1.12) and is_equal_approx(full.crit, .12+.05+.04))
	assert(is_equal_approx(full.haste, .05) and is_equal_approx(full.dodge, .02))
	assert(is_equal_approx(full.damage_reduction, .02) and full.gear_effects == ["radiance"])
	var mixed := p.duplicate(true)
	mixed.heroes.eira.equipment.boots = ""
	mixed.heroes.eira.equipment.accessory = ""
	var two := book.stats(mixed)
	assert(two.equipment_sets.dawn == 2 and is_equal_approx(two.hp, (210+115)*1.08))
	assert(is_equal_approx(two.skill_bonus, 1.12))
	for id in ["spear_ember", "armor_2", "boots_4", "accessory_4"]: wear(store, mixed, id, "ryn")
	assert(book.stats(mixed) == two, "Inspecting another build does not alter Eira")
	var fire := book.stats(mixed, "ryn")
	assert(fire.equipment_sets.ember == 4 and is_equal_approx(fire.atk, (23+18)*1.06))
	assert(is_equal_approx(fire.crit, .18+.05+.03+.05))
	for id in ["staff_tide", "armor_1", "boots_3", "armor_3"]: wear(store, mixed, id, "mira")
	var water := book.stats(mixed, "mira")
	assert(water.equipment_sets.tide == 4 and water.sp_regen == 1)
	assert(is_equal_approx(water.defense, (4+2+1+4)*1.08))
	assert(store.commit(mixed))
	assert(store.begin_run(1))
	var snapshot: Dictionary = store.profile.pending.duplicate(true)
	assert(not store.equip(store.profile.items.back().uid) and not store.enhance("starter_eira"))
	assert(ProgressStore.new(book, store.path).profile.pending == snapshot)
	assert(store.settle(snapshot.id, false, 0))
	var before := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.enhance("starter_eira") and store.profile == before)
	store.fail_writes = false
	for i in range(15): assert(store.enhance("starter_eira"))
	assert(not store.enhance("starter_eira") and EquipmentSystem.item_for(store.profile, "starter_eira").enhance == 15)
	# Real marker effects and dedicated model RNG; presentation does not drive them.
	var light := battle(full)
	assert(light.skill(0))
	ticks(light, 20)
	assert(is_equal_approx(light.barrier, full.hp*.05))
	var aegis_stats := full.duplicate(true)
	aegis_stats.gear_effects = ["aegis"]
	var aegis := battle(aegis_stats)
	assert(aegis.skill(2))
	ticks(aegis, 35)
	assert(is_equal_approx(aegis.barrier, full.hp*.08))
	var water_model := battle(water)
	var plain_water := water.duplicate(true)
	plain_water.gear_effects = []
	var control := battle(plain_water)
	assert(water_model.skill(1) and control.skill(1))
	ticks(water_model, 30)
	ticks(control, 30)
	assert(is_equal_approx(water_model.sp, control.sp+5))
	var burning := battle(fire)
	for seed in range(100):
		burning.rng.seed = seed
		if burning.rng.randf() < .15:
			burning.rng.seed = seed
			break
	burning._hit(10, false)
	assert(burning.burn_left == 3)
	var burn_hp := burning.enemy_hp
	var old_burn := burning.burn_left
	burning.paused = true
	ticks(burning, 60)
	assert(burning.burn_left == old_burn and burning.enemy_hp == burn_hp)
	burning.paused = false
	ticks(burning, 181)
	var hits := 0
	for event in burning.events:
		if event.kind == "hit" and event.visual.get("source") == "burn": hits += 1
	assert(hits == 3 and burning.enemy_hp < burn_hp)
	# New3vN model: every actor owns its gear stats and marker effects.
	var team := TeamBattle.new(book)
	var team_data := Formation.snapshot(book, mixed, book.find_row("stages", 1))
	team.start({"id":"gear_team", "stage":1, "seed":17, "stats":book.stats(mixed), "team":team_data})
	team.auto_ultimate = false
	team.enemies[0].hp = 100000
	team.enemies[0].max_hp = 100000
	team.enemies[0].clock = -100
	for actor in team.allies:
		actor.clock = -100
		actor.basic_cd = 100
	team.assist_clock = -100
	team._schedule_ally(team.allies[0], "basic", 1, .1, .2)
	for i in range(15): team.advance(BattleModel.STEP)
	assert(is_equal_approx(team.allies[0].barrier, team.allies[0].stats.hp*.05))
	for actor in team.allies:
		actor.clock = -100
		actor.energy = 0
	for i in range(60): team.advance(BattleModel.STEP)
	assert(is_equal_approx(team.allies[2].energy-team.allies[0].energy, 1))
	team.allies[0].stats.gear_effects = ["aegis"]
	team._spirit(true)
	assert(is_equal_approx(team.allies[0].barrier, team.allies[0].stats.hp*.08))
	var probe := RandomNumberGenerator.new()
	for seed in range(100):
		probe.seed = seed
		probe.randf() # Crit roll precedes burn roll in the team model.
		if probe.randf() < .15:
			team.rng.seed = seed
			break
	team._damage_enemy(0, 1, team.allies[1], false)
	assert(team.enemies[0].burn_source == 1)
	var before_dot: float = team.enemies[0].hp
	var events_before: int = team.event_sequence
	for i in range(181): team.advance(BattleModel.STEP)
	assert(team.enemies[0].hp < before_dot and team.event_sequence == events_before+3)
	var invalid_team := team_data.duplicate(true)
	invalid_team.units[1].stats.dodge = 1
	assert(not Formation.valid_snapshot(store, invalid_team))
	var invalid := store.profile.duplicate(true)
	invalid.pending = snapshot.duplicate(true)
	invalid.pending.stats.dodge = 1
	assert(not store.valid(invalid))
	# A genuine v7 shape: fourteen fragment IDs, two slots, paid moon amulet.
	var legacy := store.fresh()
	legacy.version = 7
	legacy.gold = 456
	for id in legacy.collection_fragments.items.keys():
		if id not in EquipmentSystem.OLD_ITEMS: legacy.collection_fragments.items.erase(id)
	legacy.collection_fragments.items.sword_1 = 37
	legacy.items.append({"uid":"moon", "base":"armor_3", "enhance":9, "rank":3})
	legacy.heroes.eira.equipment.armor = "moon"
	for unit in legacy.heroes.values():
		unit.equipment.erase("boots")
		unit.equipment.erase("accessory")
	legacy.pending = snapshot.duplicate(true)
	var path := directory.path_join("v7.json")
	write(path, legacy)
	var raw := FileAccess.get_file_as_bytes(path)
	var migrated := ProgressStore.new(book, path)
	assert(not migrated.read_only and migrated.profile.version == ProgressStore.VERSION)
	assert(migrated.profile.heroes.eira.equipment.armor == "" and migrated.profile.heroes.eira.equipment.accessory == "moon")
	assert(migrated.profile.collection_fragments.items.sword_1 == 37 and migrated.profile.collection_fragments.items.boots_7 == 0)
	assert(migrated.profile.items.back().enhance == 9 and migrated.profile.items.back().rank == 3 and migrated.profile.pending == snapshot)
	assert(migrated.profile.items.size() == legacy.items.size() and migrated.profile.gold == 456)
	assert(migrated.setting("speed", 2) and FileAccess.get_file_as_bytes(path+".bak") == raw)
	assert(ProgressStore.new(book, path).profile == migrated.profile)
	legacy.version = 8
	write(path+".v8", legacy)
	var migrated8 := ProgressStore.new(book, path+".v8")
	assert(not migrated8.read_only and migrated8.profile.version == ProgressStore.VERSION and migrated8.profile.pending == snapshot)
	assert(migrated8.profile.heroes.eira.equipment.accessory == "moon")
	legacy.collection_fragments.items.erase("sword_1")
	write(path+".invalid", legacy)
	assert(ProgressStore.new(book, path+".invalid").read_only)
	print("PASS: four slots, three 2/4 sets, real stat/marker effects, burn timing/pause, cap15 and atomic rollback, immutable snapshot, v7 moon migration and strict malformed-save rejection")
	quit()
