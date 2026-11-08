extends SceneTree

var book := GameCatalog.new()
var directory := "user://first_light_tests/unique_%d" % Time.get_ticks_usec()

func write(path: String, value: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(value))
	file.close()

func draw(store: ProgressStore, kind: String, id: String) -> Dictionary:
	for seed in range(10000):
		var candidate := store.profile.duplicate(true)
		Recruitment.ensure(store, candidate)
		candidate.recruitment.seed = seed
		Recruitment._draw(store, candidate)
		var reward: Dictionary = candidate.recruitment.history[0]
		if reward.kind == kind and reward.id == id: return candidate
	assert(false, "No seed for requested test reward")
	return {}

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute(directory)
	var store := ProgressStore.new(book, directory.path_join("new.json"))
	assert(store.valid(store.profile) and store.profile.items.size() == 3)
	assert(store.profile.heroes.ryn.equipment.weapon == store.profile.heroes.lyra.equipment.weapon)
	var p := store.profile.duplicate(true)
	p.gold = 100000
	p.shards = 1000
	assert(store.commit(p))
	var uid_counter: int = store.profile.next_uid
	assert(store.forge("sword_1"))
	assert(store.profile.items.size() == 4 and store.profile.next_uid == uid_counter+1)
	assert(store.profile.collection_fragments.items.sword_1 == 0)
	assert(store.profile.collection_fragments.items.sword_2 == 0)
	assert(store.forge("sword_2") and store.profile.items.size() == 5)
	assert(store.profile.collection_fragments.items.sword_2 == 0)
	var before := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.forge("sword_1") and store.profile == before)
	store.fail_writes = false
	for kind in ["hero", "spirit", "item"]:
		var id: String = {"hero": "ryn", "spirit": "ash", "item": "armor_5"}[kind]
		var first := draw(store, kind, id)
		assert(not first.recruitment.history[0]["duplicate"])
		assert(store.commit(first))
		var second := draw(store, kind, id)
		if kind == "item": assert(not second.recruitment.history[0]["duplicate"])
		else: assert(second.recruitment.history[0]["duplicate"] and second.recruitment.history[0].fragment_amount == 10)
		if kind == "hero": assert(second.recruitment.fragments.ryn == first.recruitment.fragments.ryn + 10)
		elif kind == "spirit":
			assert(second.collection_fragments.spirits.ash == first.collection_fragments.spirits.ash + 10)
			assert(second.collection_fragments.spirits.lumi == first.collection_fragments.spirits.lumi)
			assert(second.expansion.cores == first.expansion.cores)
		else:
			assert(second.items.size() == first.items.size()+1 and second.next_uid == first.next_uid+1)
			assert(second.collection_fragments.items.armor_5 == first.collection_fragments.items.armor_5)
		assert(store.commit(second))
	assert(store.begin_run(1))
	var pending: Dictionary = store.profile.pending.duplicate(true)
	assert(not store.forge("sword_1") and not Recruitment.summon(store, 10))
	var owned := store.profile.duplicate(true)
	for row in book.data.items: store._add_item(owned, row.id)
	assert(store.commit(owned))
	before = store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.settle(pending.id, true, 3) and store.profile == before)
	store.fail_writes = false
	assert(store.settle(pending.id, true, 3))
	var gained := 0
	for id in before.collection_fragments.items: gained += store.profile.collection_fragments.items[id] - before.collection_fragments.items[id]
	assert(gained == 0)
	var settled := store.profile.duplicate(true)
	assert(store.settle(pending.id, true, 3) and store.profile == settled)
	assert(ProgressStore.new(book, store.path).profile == settled)
	# Legacy inventory: two paid spear copies equipped to different heroes.
	var legacy := store.fresh()
	legacy.version = 6
	legacy.erase("collection_fragments")
	legacy.gold = 321
	legacy.recruitment = Recruitment.fresh()
	legacy.recruitment.fragments.ryn = 27
	legacy.recruitment.history = [
		{"kind": "item", "id": "sword_1", "rarity": 1, "duplicate": false},
		{"kind": "item", "id": "armor_uncommon", "rarity": 2, "duplicate": false},
		{"kind": "spirit", "id": "lumi", "rarity": 1, "duplicate": true}]
	legacy.expansion.cores = 13
	legacy.items[1].enhance = 8
	legacy.items.append({"uid": "paid_spear", "base": "spear_1", "enhance": 2, "rank": 3})
	legacy.heroes.lyra.equipment.weapon = "paid_spear"
	legacy.pending = pending.duplicate(true)
	legacy.next_uid = 250
	var path := directory.path_join("legacy.json")
	write(path, legacy)
	var original := FileAccess.get_file_as_bytes(path)
	var migrated := ProgressStore.new(book, path)
	assert(not migrated.read_only and migrated.profile.version == ProgressStore.VERSION)
	assert(migrated.profile.items.size() == 4 and migrated.profile.items[1].enhance == 8 and migrated.profile.items[1].rank == 1 and migrated.profile.items[-1].rank == 3)
	assert(migrated.profile.collection_fragments.items.spear_1 == 0)
	assert(migrated.profile.heroes.lyra.equipment.weapon == "paid_spear")
	assert(migrated.profile.pending == pending and migrated.profile.gold == 321 and migrated.profile.next_uid == 250)
	assert(migrated.profile.recruitment.fragments.ryn == 27 and migrated.profile.expansion.cores == 13)
	assert(migrated.profile.recruitment.history[0].rarity == 3 and migrated.profile.recruitment.history[1].rarity == 3)
	assert(migrated.profile.recruitment.history[0].legacy_rarity == 1 and migrated.profile.recruitment.history[1].legacy_rarity == 2)
	assert(not migrated.profile.recruitment.history[2].has("fragment_amount"))
	migrated.fail_writes = true
	assert(not migrated.setting("speed", 2) and FileAccess.get_file_as_bytes(path) == original)
	migrated.fail_writes = false
	assert(migrated.setting("speed", 2) and FileAccess.get_file_as_bytes(path + ".bak") == original)
	assert(ProgressStore.new(book, path).profile == migrated.profile)
	for version in [2, 3, 4, 5]:
		legacy.version = version
		write(path + str(version), legacy)
		var older := ProgressStore.new(book, path + str(version))
		assert(not older.read_only and older.profile.pending == pending and older.profile.collection_fragments.items.spear_1 == 0)
	# Bad current/legacy data must never be silently repaired or credited.
	var bad := migrated.profile.duplicate(true)
	bad.items.append({"uid": "starter_ryn", "base": "spear_1", "enhance": 0, "rank": 1})
	assert(not migrated.valid(bad))
	write(path + ".invalid", bad)
	assert(ProgressStore.new(book, path + ".invalid").read_only)
	bad = legacy.duplicate(true)
	bad.items[-1].enhance = 99
	write(path + ".invalid_old", bad)
	assert(ProgressStore.new(book, path + ".invalid_old").read_only)
	bad = migrated.profile.duplicate(true)
	bad.collection_fragments.spirits.ash = -1
	assert(not migrated.valid(bad))
	bad = migrated.profile.duplicate(true)
	bad.collection_fragments.items.unknown = 10
	assert(not migrated.valid(bad))
	assert(CollectionFragments.reward_suffix({"kind": "spirit", "duplicate": true}) == " · +2 Cores (legacy run)")
	print("PASS: multiple gear copies, hero/spirit duplicate fragments, named ledgers, forge/loot, atomic failure/retry, v2-v6 migration, separate paid upgrades, shared gear, unchanged snapshots/backups and strict invalid-save rejection")
	quit()
