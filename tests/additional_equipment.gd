extends SceneTree

var book := GameCatalog.new()
var folder := "user://first_light_tests/new_sets_%d" % Time.get_ticks_usec()

func write(path: String,p: Dictionary) -> void:
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(p,"",true,true))
	file.close()

func equip_piece(store: ProgressStore,p: Dictionary,base: String,hero: String) -> void:
	assert(store._add_item(p,base))
	p.heroes[hero].equipment[book.find_row("items",base).slot] = p.items.back().uid

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	assert(book.errors.is_empty() and book.data.items.size() == 44 and book.data.sets.size() == 6)
	for set_id in EquipmentSystem.ADDED_SETS:
		for hero in ["eira","ryn","mira"]:
			var store := ProgressStore.new(book,folder.path_join(set_id+hero+".json"))
			var p := store.profile.duplicate(true)
			p.cleared = [1,2,3]
			var names := [book.category(hero),"armor","boots","accessory"]
			for count in range(4):
				equip_piece(store,p,names[count]+"_"+set_id,hero)
				assert(store.valid(p))
				var actual: Dictionary = book.stats(p,hero)
				var definitions: Array = book.data.sets
				book.data.sets = []
				var without: Dictionary = book.stats(p,hero)
				book.data.sets = definitions
				if set_id == "grove":
					assert(is_equal_approx(actual.hp,without.hp*(1.08 if count >= 1 else 1.0)))
					assert(is_equal_approx(actual.damage_reduction,without.damage_reduction+(.06 if count == 3 else 0.0)))
				elif set_id == "storm":
					assert(is_equal_approx(actual.haste,without.haste+(.06 if count >= 1 else 0.0)))
					assert(is_equal_approx(actual.crit,without.crit+(.05 if count == 3 else 0.0)))
				else:
					assert(is_equal_approx(actual.sp_regen,without.sp_regen+(.5 if count >= 1 else 0.0)))
					assert(is_equal_approx(actual.skill_bonus,without.skill_bonus*(1.10 if count == 3 else 1.0)))
			assert(store.commit(p) and store.begin_run(1))
			var pending: Dictionary = store.profile.pending.duplicate(true)
			var model := TeamBattle.new(book)
			model.start(pending)
			var unit: Dictionary = model.allies.filter(func(a): return a.id == hero)[0]
			assert(unit.stats.equipment_sets[set_id] == 4)
			assert(not store.forge("armor_grove") and store.profile.pending == pending)
	var forge := ProgressStore.new(book,folder.path_join("forge.json"))
	var rich := forge.profile.duplicate(true)
	rich.gold = 10000
	rich.shards = 100
	assert(forge.commit(rich))
	for kind in ["sword","spear","staff","armor","boots","accessory"]:
		assert(forge.forge(kind+"_grove"))
	assert(forge.profile.gold == 9610 and forge.profile.shards == 82)
	assert(not forge.forge("sword_storm") and not forge.forge("staff_moon"))
	for set_id in EquipmentSystem.ADDED_SETS:
		for kind in ["sword","spear","staff","armor","boots","accessory"]:
			var pool := Recruitment.pool(book,2 if set_id == "grove" else 3)
			assert(pool.any(func(entry): return entry.id == kind+"_"+set_id))
	# A genuine v10 contains only the former26 fragment IDs and duplicate UIDs.
	var legacy := forge.fresh()
	legacy.version = 10
	legacy.gold = 987
	legacy.bag_rewards = ["armor_5"]
	for id in legacy.collection_fragments.items.keys():
		if not EquipmentSystem.previous_item(book,id): legacy.collection_fragments.items.erase(id)
	legacy.collection_fragments.items.sword_1 = 73
	assert(forge._add_item(legacy,"armor_4") and forge._add_item(legacy,"armor_4"))
	legacy.items.back().enhance = 9
	legacy.items.back().rank = 2
	legacy.heroes.eira.equipment.armor = legacy.items.back().uid
	var path := folder.path_join("v10.json")
	# Build the old frozen run from old items; never recalculate it during migration.
	var temp := forge.profile.duplicate(true)
	temp.items = legacy.items.duplicate(true)
	temp.heroes = legacy.heroes.duplicate(true)
	assert(forge.commit(temp) and forge.begin_run(1))
	legacy.pending = forge.profile.pending.duplicate(true)
	write(path,legacy)
	var raw := FileAccess.get_file_as_bytes(path)
	var migrated := ProgressStore.new(book,path)
	assert(not migrated.read_only and migrated.profile.version == 11)
	for key in ["items","gold","next_uid","heroes","bag_rewards","pending"]: assert(migrated.profile[key] == legacy[key])
	for id in legacy.collection_fragments.items: assert(migrated.profile.collection_fragments.items[id] == legacy.collection_fragments.items[id])
	for id in migrated.profile.collection_fragments.items:
		if not EquipmentSystem.previous_item(book,id): assert(migrated.profile.collection_fragments.items[id] == 0)
	migrated.fail_writes = true
	assert(not migrated.setting("sound",false) and FileAccess.get_file_as_bytes(path) == raw)
	migrated.fail_writes = false
	assert(migrated.setting("sound",false) and FileAccess.get_file_as_bytes(path+".bak") == raw)
	assert(ProgressStore.new(book,path).profile == migrated.profile)
	var broken := legacy.duplicate(true)
	broken.collection_fragments.items.erase("sword_1")
	write(path+"bad",broken)
	assert(ProgressStore.new(book,path+"bad").read_only)
	broken = migrated.profile.duplicate(true)
	broken.collection_fragments.items.erase("sword_grove")
	write(path+"bad11",broken)
	assert(ProgressStore.new(book,path+"bad11").read_only)
	print("PASS: three sets across three classes, 1/2/3/4 piece thresholds, team snapshots, forge/pools, strict v10 migration, duplicate UID/investment/queued loot/pending preservation and rollback")
	quit()
