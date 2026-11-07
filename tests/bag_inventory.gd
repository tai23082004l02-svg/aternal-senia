extends SceneTree
var book := GameCatalog.new()
var directory := "user://first_light_tests/bag_%d" % Time.get_ticks_usec()

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var store := ProgressStore.new(book,directory.path_join("save.json"))
	var p := store.profile.duplicate(true)
	p.gold = 100000
	p.shards = 1000
	assert(store.commit(p))
	assert(store.forge("sword_1",3))
	var copies: Array = store.profile.items.filter(func(item): return item.base == "sword_1")
	assert(copies.size() == 4 and copies[0].uid != copies[1].uid)
	assert(store.profile.collection_fragments.items.sword_1 == 0)
	assert(store.enhance(copies[1].uid))
	assert(EquipmentSystem.item_for(store.profile,copies[0].uid).enhance == 0)
	assert(EquipmentSystem.item_for(store.profile,copies[1].uid).enhance == 1)
	var target: String = copies[1].uid
	var donors := store.fusion_donors(target)
	assert(donors.size() == 2 and copies[0].uid not in donors)
	var before := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.fuse(target,donors) and store.profile == before)
	store.fail_writes = false
	assert(store.fuse(target,donors))
	assert(EquipmentSystem.item_for(store.profile,target).rank == 2 and EquipmentSystem.item_for(store.profile,target).enhance == 1)
	assert(store.profile.items.size() == before.items.size()-2)
	assert(not store.fuse(target,donors))
	assert(not store.dismantle_many([target,"starter_eira"]))
	assert(not store.dismantle_many([target,target]))
	before = store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.dismantle_many([target]) and store.profile == before)
	store.fail_writes = false
	assert(store.dismantle_many([target]))
	assert(store.profile.shards == before.shards+3)
	assert(store.forge("armor_1",10))
	p = store.profile.duplicate(true)
	while p.items.size() < 40: assert(store._add_item(p,"armor_1"))
	assert(store.commit(p))
	before = store.profile.duplicate(true)
	assert(not store.forge("sword_1",1) and store.profile == before)
	# Batch must roll back price, history, RNG count and earlier hero fragments.
	assert(not Recruitment.summon(store,10) and store.profile == before)
	assert(store.begin_run(1))
	var pending: Dictionary = store.profile.pending.duplicate(true)
	var fragments: Dictionary = store.profile.collection_fragments.items.duplicate(true)
	assert(store.settle(pending.id,true,3))
	assert(store.profile.items.size() == 40 and store.profile.bag_rewards.size() == 1)
	assert(store.profile.collection_fragments.items == fragments)
	var saved := store.profile.duplicate(true)
	assert(store.settle(pending.id,true,3) and store.profile == saved)
	assert(ProgressStore.new(book,store.path).profile == saved)
	assert(not store.claim_bag_rewards())
	var spare: String = store.profile.items.back().uid
	assert(store.dismantle(spare))
	before = store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.claim_bag_rewards() and store.profile == before)
	store.fail_writes = false
	assert(store.claim_bag_rewards() and store.profile.bag_rewards.is_empty() and store.profile.items.size() == 40)
	assert(not store.claim_bag_rewards())
	# Genuine v9 keeps all old paid items/fragments and frozen team data.
	var legacy := store.fresh()
	legacy.version = 9
	legacy.erase("bag_rewards")
	legacy.collection_fragments.items.sword_1 = 70
	legacy.pending = pending.duplicate(true)
	legacy.gold = 1234
	var path := directory.path_join("v9.json")
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy,"",true,true))
	file.close()
	var bytes := FileAccess.get_file_as_bytes(path)
	var migrated := ProgressStore.new(book,path)
	assert(not migrated.read_only and migrated.profile.version == ProgressStore.VERSION)
	assert(migrated.profile.items == legacy.items and migrated.profile.collection_fragments == legacy.collection_fragments and migrated.profile.pending == legacy.pending)
	assert(migrated.setting("sound",false) and FileAccess.get_file_as_bytes(path+".bak") == bytes)
	var invalid := migrated.profile.duplicate(true)
	invalid.bag_rewards = ["missing_item"]
	assert(not migrated.valid(invalid))
	invalid = migrated.profile.duplicate(true)
	invalid.items.append(invalid.items[0].duplicate(true))
	assert(not migrated.valid(invalid))
	print("PASS: per-copy UID/upgrades, craft batch, safe fusion/bulk dismantle, capacity and atomic summon rollback, queued real loot/reload/idempotency, v9 snapshot/fragments migration")
	quit()
