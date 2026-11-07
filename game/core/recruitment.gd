class_name Recruitment
extends RefCounted

const PRICE := 120
const RARITIES := {1: {"name": "Thường", "color": "b8c4c9"}, 2: {"name": "Hiếm", "color": "86caff"}, 3: {"name": "Sử thi", "color": "d7a4ff"}}

static func rarity(kind: String, id: String, book: GameCatalog) -> int:
	if kind == "item": return int(book.find_row("items", id).get("rarity", 1))
	return 2 if id in ["eira", "lumi"] else 3

static func fresh() -> Dictionary:
	return {"seed": 17, "count": 0, "pity": 0, "heroes": [], "spirits": [], "fragments": {"eira": 0, "ryn": 0, "mira": 0}, "awakening": {"eira": 1, "ryn": 1, "mira": 1}, "history": []}

static func state(p: Dictionary) -> Dictionary:
	return p.get("recruitment", fresh())

static func ensure(store: ProgressStore, p: Dictionary) -> void:
	if not p.has("recruitment"):
		p.recruitment = fresh()
		p.recruitment.seed = absi(store.path.hash()) % 2147483647

static func valid(store: ProgressStore, p: Dictionary) -> bool:
	if not p.has("recruitment"): return true
	var r = p.recruitment
	if not r is Dictionary: return false
	for key in fresh():
		if not r.has(key): return false
	for key in ["seed", "count", "pity"]:
		if not store._whole(r[key], 0, 19 if key == "pity" else 2147483647): return false
	for key in ["heroes", "spirits"]:
		if not r[key] is Array or not Expansion.unique(r[key]): return false
		for id in r[key]:
			if store.catalog.find_row("heroes" if key == "heroes" else "assists", id).is_empty(): return false
	if not r.fragments is Dictionary or not r.awakening is Dictionary: return false
	for hero in store.catalog.data.heroes:
		if not store._whole(r.fragments.get(hero.id), 0, 1e12) or not store._whole(r.awakening.get(hero.id), 1, 3): return false
	if not r.history is Array or r.history.size() > 10: return false
	for entry in r.history:
		if not entry is Dictionary or entry.get("kind") not in ["hero", "spirit", "item"] or not entry.get("duplicate") is bool: return false
		var group: String = {"hero": "heroes", "spirit": "assists", "item": "items"}[entry.kind]
		if store.catalog.find_row(group, entry.get("id")).is_empty() or entry.get("rarity") != rarity(entry.kind, entry.id, store.catalog): return false
	return true

static func pool(book: GameCatalog, tier: int) -> Array:
	var result: Array = []
	for pair in [["hero", "heroes"], ["spirit", "assists"], ["item", "items"]]:
		for row in book.data[pair[1]]:
			if rarity(pair[0], row.id, book) == tier: result.append({"kind": pair[0], "id": row.id, "rarity": tier})
	return result

static func summon(store: ProgressStore) -> bool:
	if store.read_only or not store.profile.pending.is_empty() or store.profile.gold < PRICE: return false
	var p := store.profile.duplicate(true)
	ensure(store, p)
	var r: Dictionary = p.recruitment
	if r.count >= 2147483647: return false
	var rng := RandomNumberGenerator.new()
	rng.seed = int(r.seed) + int(r.count) * 7919
	var roll := rng.randi_range(0, 9999)
	var tier := 3 if r.pity >= 19 or roll >= 9500 else (2 if roll >= 7000 else 1)
	var candidates := pool(store.catalog, tier)
	var reward: Dictionary = candidates[rng.randi_range(0, candidates.size() - 1)].duplicate(true)
	reward["duplicate"] = false
	p.gold -= PRICE
	match reward.kind:
		"item": store._add_item(p, reward.id)
		"hero":
			reward["duplicate"] = store.available_hero(reward.id)
			if reward.id not in r.heroes: r.heroes.append(reward.id)
			if reward["duplicate"]: r.fragments[reward.id] += 10
		"spirit":
			reward["duplicate"] = store.available_assist(reward.id)
			if reward.id not in r.spirits: r.spirits.append(reward.id)
			if reward["duplicate"]: p.expansion.cores += 2
	r.count += 1
	r.pity = 0 if tier == 3 else r.pity + 1
	r.history.push_front(reward)
	if r.history.size() > 10: r.history.pop_back()
	return store.commit(p)

static func awaken(store: ProgressStore, hero_id: String = "") -> bool:
	if store.read_only or not store.profile.pending.is_empty(): return false
	var p := store.profile.duplicate(true)
	ensure(store, p)
	var target: String = p.hero if hero_id.is_empty() else hero_id
	if not store.available_hero(target): return false
	var rank: int = p.recruitment.awakening[target]
	if rank >= 3 or p.heroes[target].level < rank * 10 or p.gold < rank * 200 or p.recruitment.fragments[target] < rank * 20: return false
	p.gold -= rank * 200
	p.recruitment.fragments[target] -= rank * 20
	p.recruitment.awakening[target] += 1
	return store.commit(p)

static func level_batch(store: ProgressStore, count: int = 5, hero_id: String = "") -> bool:
	if count < 1 or count > 5 or store.read_only or not store.profile.pending.is_empty(): return false
	var p := store.profile.duplicate(true)
	var target: String = p.hero if hero_id.is_empty() else hero_id
	if not store.available_hero(target): return false
	var unit: Dictionary = p.heroes[target]
	if unit.level >= 100: return false
	for i in range(mini(count, 100 - unit.level)):
		if p.gold < unit.level * 30 or p.xp < unit.level * 15: return false
		p.gold -= unit.level * 30
		p.xp -= unit.level * 15
		unit.level += 1
	return store.commit(p)
