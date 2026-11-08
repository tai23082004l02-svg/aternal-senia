extends SceneTree
var book := GameCatalog.new()
var folder := "user://first_light_tests/supplies_%d" % Time.get_ticks_usec()

func _initialize() -> void: call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	var store := ProgressStore.new(book,folder.path_join("save.json"))
	var p := store.profile.duplicate(true)
	p.gold = 10000
	p.shards = 100
	p.cleared = [1,2,3]
	for id in Supplies.ORDER: p.supplies.counts[id] = 20
	assert(store.commit(p))
	var before := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not Supplies.buy(store,"rage_potion") and store.profile==before)
	assert(not Supplies.claim(store,"story_1") and store.profile==before)
	assert(not Supplies.open_chest(store,"forge_stone") and store.profile==before)
	store.fail_writes = false
	assert(Supplies.claim(store,"story_1"))
	assert(not Supplies.claim(store,"story_1"))
	assert(not Supplies.open_chest(store,"normal_ticket"))
	before = store.profile.duplicate(true)
	assert(Supplies.open_chest(store,"memory_shard"))
	assert(store.profile.supplies.counts.memory_shard==before.supplies.counts.memory_shard+2 and store.profile.items==before.items)
	p = store.profile.duplicate(true)
	assert(store._add_item(p,"armor_1") and store._add_item(p,"armor_1"))
	assert(store.commit(p))
	var uid: String = store.profile.items[-1].uid
	var other: String = store.profile.items[-2].uid
	before = store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.enhance(uid,false,true) and store.profile==before)
	store.fail_writes = false
	assert(store.enhance(uid,false,true))
	assert(EquipmentSystem.item_for(store.profile,uid).enhance==1 and EquipmentSystem.item_for(store.profile,other).enhance==0)
	assert(store.profile.gold==before.gold-20 and store.profile.shards==before.shards and store.profile.supplies.counts.forge_stone==before.supplies.counts.forge_stone-1)
	before = store.profile.duplicate(true)
	assert(not store.enhance(uid,true,true) and store.profile==before)
	assert(Supplies.train(store,"mira",0))
	assert(store.profile.heroes.mira.skills[0]==2 and store.profile.heroes.eira.skills[0]==1)
	assert(store.profile.gold==before.gold)
	assert(not Supplies.train(store,"mira",2))
	before = store.profile.duplicate(true)
	assert(Supplies.refine_seed(store))
	assert(store.profile.expansion.cores==before.expansion.cores+1 and store.profile.supplies.counts.ancient_seed==before.supplies.counts.ancient_seed-3)
	before = store.profile.duplicate(true)
	var idle: int = store.offline_preview(int(store.profile.last_offline)+600)
	assert(Supplies.hourglass(store))
	assert(store.profile.gold==before.gold+store.offline_amount(7200) and store.profile.last_offline==before.last_offline)
	assert(store.offline_preview(int(store.profile.last_offline)+600)==idle)
	assert(not Supplies.buy(store,"afk_hourglass"))
	assert(Supplies.select_support(store,"rage_potion"))
	before = store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.begin_run(101) and store.profile==before)
	store.fail_writes = false
	var base_stats := book.stats(store.profile)
	assert(store.begin_run(101))
	assert(store.profile.supplies.counts.rage_potion==before.supplies.counts.rage_potion-1 and store.profile.supplies.selected=="")
	assert(is_equal_approx(store.profile.pending.stats.atk,base_stats.atk*1.1))
	var run: Dictionary = store.profile.pending.duplicate(true)
	var loaded := ProgressStore.new(book,store.path)
	assert(loaded.profile.pending==run)
	var battle := TeamBattle.new(book)
	battle.start(loaded.profile.pending)
	assert(is_equal_approx(battle.allies[0].stats.atk,base_stats.atk*1.1))
	assert(not loaded.begin_run(101))
	before = loaded.profile.duplicate(true)
	assert(not Supplies.hourglass(loaded) and not Supplies.select_support(loaded,"ward_potion") and loaded.profile==before)
	assert(loaded.settle(run.id,false,0))
	assert(loaded.profile.supplies.counts.rage_potion==before.supplies.counts.rage_potion)
	assert(Supplies.select_support(loaded,"ward_potion"))
	var defense: float = book.stats(loaded.profile).defense
	assert(loaded.begin_run(101))
	assert(is_equal_approx(loaded.profile.pending.stats.defense,defense*1.1))
	assert(loaded.settle(loaded.profile.pending.id,false,0))
	assert(loaded.begin_run(101))
	assert(not loaded.profile.pending.has("support"))
	run = loaded.profile.pending.duplicate(true)
	var seeds: int = loaded.profile.supplies.counts.ancient_seed
	assert(loaded.settle(run.id,true,3))
	assert(loaded.profile.supplies.counts.ancient_seed==seeds+1)
	before = loaded.profile.duplicate(true)
	assert(loaded.settle(run.id,true,3) and loaded.profile==before)
	# Full physical bag never limits a material chest, and a ticket batch rolls back.
	p = loaded.profile.duplicate(true)
	while p.items.size()<40: assert(loaded._add_item(p,"armor_1"))
	p.gold = 0
	p.recruitment = Recruitment.fresh()
	p.recruitment.seed = 1234
	assert(loaded.commit(p))
	before = loaded.profile.duplicate(true)
	assert(not Recruitment.summon(loaded,10,true) and loaded.profile==before)
	assert(Supplies.open_chest(loaded,"forge_stone") and loaded.profile.items.size()==40)
	var spare: String = loaded.profile.items[-1].uid
	assert(loaded.dismantle(spare))
	before = loaded.profile.duplicate(true)
	loaded.fail_writes = true
	assert(not Recruitment.summon(loaded,1,true) and loaded.profile==before)
	loaded.fail_writes = false
	assert(Recruitment.summon(loaded,1,true))
	assert(loaded.profile.gold==0 and loaded.profile.supplies.counts.normal_ticket==before.supplies.counts.normal_ticket-1)
	assert(loaded.profile.recruitment.count==before.recruitment.count+1)
	var invalid := loaded.profile.duplicate(true)
	invalid.supplies.counts["forged_id"] = 1
	assert(not loaded.valid(invalid))
	invalid = loaded.profile.duplicate(true)
	invalid.supplies.counts.normal_ticket = -1
	assert(not loaded.valid(invalid))
	# Real v10 preserves duplicate gear, fragments, balances and frozen pending team.
	var legacy := store.fresh()
	legacy.gold = 987
	legacy.cleared = [1]
	assert(store._add_item(legacy,"sword_1"))
	legacy.collection_fragments.items.sword_1 = 70
	assert(store.commit(legacy) and store.begin_run(101))
	legacy = store.profile.duplicate(true)
	legacy.version = 10
	legacy.erase("supplies")
	var path := folder.path_join("v10.json")
	var file := FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy,"",true,true))
	file.close()
	var bytes := FileAccess.get_file_as_bytes(path)
	var migrated := ProgressStore.new(book,path)
	assert(not migrated.read_only and migrated.profile.version==11)
	assert(migrated.profile.items==legacy.items and migrated.profile.collection_fragments==legacy.collection_fragments and migrated.profile.pending==legacy.pending)
	assert(migrated.profile.supplies==Supplies.fresh())
	assert(migrated.setting("sound",false) and FileAccess.get_file_as_bytes(path+".bak")==bytes)
	print("PASS: stackable ledger, one-time claims, choice chest, per-UID stone upgrade, skill/seed/AFK, snapshot-only support and reload, ticket atomicity/full bag, v10 migration/backup and validation")
	quit()
