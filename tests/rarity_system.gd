extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var book := GameCatalog.new()
	var tiers := {}
	for item in book.data.items: tiers[item.rarity] = true
	assert(tiers.size() == 5 and Recruitment.RARITIES.size() == 5)
	for tier in [3, 4, 5, 6, 7]: assert(tiers.has(tier) and Recruitment.RARITIES.has(tier))
	assert(Recruitment.label("item", "sword_1", book) == "Rare")
	assert(Recruitment.label("item", "armor_uncommon", book) == "Rare")
	var names: Array = []
	for tier in Recruitment.RARITIES: names.append(Recruitment.RARITIES[tier].name)
	assert(names == ["Rare", "Epic", "Legendary", "Mythic", "Divine"])
	assert(book.find_row("items", "sword_1").cooldown_scale == 1.0)
	assert(book.find_row("items", "sword_2").cooldown_scale == .92)
	assert(book.find_row("items", "sword_1").summon_group == 1 and book.find_row("items", "sword_2").summon_group == 2)
	assert(Recruitment.label("spirit", "lumi", book) == "SR")
	assert(Recruitment.label("spirit", "ash", book) == "SSR")
	assert(Recruitment.SPIRIT_RARITIES[3].name == "UR")
	var path := "user://first_light_tests/rarity_%d.json" % Time.get_ticks_usec()
	var store := ProgressStore.new(book, path)
	assert(Recruitment.label("hero", "eira", book, store.profile) == "5★" and Recruitment.state(store.profile).awakening.eira == 1)
	var p := store.profile.duplicate(true)
	p.heroes.eira.level = 50
	p.gold = 10000
	p.recruitment = Recruitment.fresh()
	p.recruitment.fragments.eira = 1000
	assert(store.commit(p))
	for i in range(4): assert(Recruitment.awaken(store))
	assert(store.profile.recruitment.awakening.eira == 5 and not Recruitment.awaken(store))
	assert(store.profile.gold == 8000 and store.profile.recruitment.fragments.eira == 800)
	assert(Recruitment.label("hero", "eira", book, store.profile) == "5★")
	assert(ProgressStore.new(book, path).profile.recruitment.awakening.eira == 5)
	var legacy := store.profile.duplicate(true)
	legacy.version = 4
	legacy.recruitment.history = [
		{"kind": "item", "id": "armor_4", "rarity": 3, "duplicate": false},
		{"kind": "item", "id": "sword_2", "rarity": 2, "duplicate": false},
		{"kind": "hero", "id": "ryn", "rarity": 3, "duplicate": true},
		{"kind": "spirit", "id": "lumi", "rarity": 2, "duplicate": true}]
	var legacy_path := path + "_v4"
	var file := FileAccess.open(legacy_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy))
	file.close()
	var bytes := FileAccess.get_file_as_bytes(legacy_path)
	var migrated := ProgressStore.new(book, legacy_path)
	assert(not migrated.read_only and migrated.profile.version == ProgressStore.VERSION)
	for i in range(4): assert(migrated.profile.recruitment.history[i].rarity == [4, 3, 5, 1][i])
	assert(migrated.profile.gold == legacy.gold and migrated.profile.items == legacy.items)
	assert(migrated.profile.recruitment.awakening == legacy.recruitment.awakening)
	assert(migrated.setting("sound", false))
	assert(FileAccess.get_file_as_bytes(legacy_path + ".bak") == bytes)
	var weights := {}
	for entry in Recruitment.pool(book, 3): weights[entry.id] = entry.weight
	assert(weights.armor_7 < weights.armor_6 and weights.armor_6 < weights.armor_5 and weights.armor_5 < weights.armor_4)
	print("PASS: five equipment tiers, five hero stars, SR/SSR/UR, star costs/cap, v4 migration/backup and high-tier weights")
	quit()
