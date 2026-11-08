class_name Recruitment
extends RefCounted

const PRICE := 120
const HISTORY_LIMIT := 100
const RARITIES := {
	3: {"name": "Rare", "color": "608dff"},
	4: {"name": "Epic", "color": "aa70ff"},
	5: {"name": "Legendary", "color": "efa52c"},
	6: {"name": "Mythic", "color": "ef5555"},
	7: {"name": "Divine", "color": "e5c569"}
}
const SPIRIT_RARITIES := {1: {"name": "SR", "color": "86caff"}, 2: {"name": "SSR", "color": "d7a4ff"}, 3: {"name": "UR", "color": "e5c569"}}
const GROUP_NAMES := {1: "Basic", 2: "Advanced", 3: "Premium"}

static func rarity(kind: String, id: String, book: GameCatalog) -> int:
	if kind == "item": return int(book.find_row("items", id).get("rarity", 3))
	if kind == "spirit": return {"SR": 1, "SSR": 2, "UR": 3}.get(book.find_row("assists", id).get("rarity", "SR" if id == "lumi" else "SSR"), 1)
	return int(book.find_row("heroes", id).get("rarity", 5))

static func label(kind: String, id: String, book: GameCatalog, profile: Dictionary = {}) -> String:
	if kind == "item": return RARITIES[rarity(kind, id, book)].name
	if kind == "spirit": return SPIRIT_RARITIES[rarity(kind, id, book)].name
	return "%d★" % rarity(kind, id, book)

static func color(kind: String, id: String, book: GameCatalog, profile: Dictionary = {}) -> Color:
	if kind == "spirit": return Color(SPIRIT_RARITIES[rarity(kind, id, book)].color)
	var tier := rarity(kind, id, book)
	if kind == "hero": return Color({1: "a4aab5", 2: "69b875", 3: "608dff", 4: "aa70ff", 5: "efa52c"}[tier])
	return Color(RARITIES[tier].color)

static func fresh(book: GameCatalog = null) -> Dictionary:
	var result := {"seed": 17, "count": 0, "pity": 0, "heroes": [], "spirits": [], "fragments": {}, "awakening": {}, "history": []}

	result.fragments = {}
	result.awakening = {}
	var rows: Array = book.data.heroes if book != null else GameCatalog.new().data.heroes
	for hero in rows:
		result.fragments[hero.id] = 0
		result.awakening[hero.id] = 1
	return result

static func state(p: Dictionary) -> Dictionary:
	return p.recruitment if p.has("recruitment") else fresh()

# Dedicated future banner counters; legacy normal pity stays separate.
static func banner_pity(p: Dictionary, banner: String) -> int:
	return int(state(p).get("banner_pity", {}).get(banner, 0))

static func ensure(store: ProgressStore, p: Dictionary) -> void:
	if not p.has("recruitment"):
		p.recruitment = fresh(store.catalog)
		p.recruitment.seed = absi(store.path.hash()) % 2147483647

static func valid(store: ProgressStore, p: Dictionary) -> bool:
	if not p.has("recruitment"): return true
	var r = p.recruitment
	if not r is Dictionary: return false
	for key in fresh(store.catalog):
		if not r.has(key): return false
	for key in ["seed", "count", "pity"]:
		if not store._whole(r[key], 0, 19 if key == "pity" else 2147483647): return false
	for key in ["heroes", "spirits"]:
		if not r[key] is Array or not Expansion.unique(r[key]): return false
		for id in r[key]:
			if store.catalog.find_row("heroes" if key == "heroes" else "assists", id).is_empty(): return false
	if r.has("banner_pity"):
		if not r.banner_pity is Dictionary: return false
		for key in ["premium", "event"]:
			if not store._whole(r.banner_pity.get(key), 0, 2147483647): return false
	if not r.fragments is Dictionary or not r.awakening is Dictionary: return false
	for hero in store.catalog.data.heroes:
		if not store._whole(r.fragments.get(hero.id), 0, 1e12) or not store._whole(r.awakening.get(hero.id), 1, 5): return false
	if not r.history is Array or r.history.size() > HISTORY_LIMIT: return false
	if r.has("last_batch"):
		var batch = r.last_batch
		if not batch is Dictionary or batch.get("end_count") != r.count or not batch.get("entries") is Array or batch.entries.size() not in [1,10]: return false
		if batch.entries != r.history.slice(0,batch.entries.size()): return false
	for entry in r.history:
		if not entry is Dictionary or entry.get("kind") not in ["hero", "spirit", "item"] or not entry.get("duplicate") is bool: return false
		if entry.has("fragment_amount") and (not entry["duplicate"] or entry.fragment_amount != CollectionFragments.DUPLICATE_AMOUNT): return false
		var group: String = {"hero": "heroes", "spirit": "assists", "item": "items"}[entry.kind]
		if store.catalog.find_row(group, entry.get("id")).is_empty() or entry.get("rarity") != rarity(entry.kind, entry.id, store.catalog): return false
	return true

static func pool(book: GameCatalog, tier: int) -> Array:
	var result: Array = []
	for pair in [["hero", "heroes"], ["spirit", "assists"], ["item", "items"]]:
		for row in book.data[pair[1]]:
			var rank := rarity(pair[0], row.id, book)
			var grade := int(row.summon_group) if pair[0] == "hero" else (2 if row.id == "lumi" else 3)
			if pair[0] == "item": grade = int(row.summon_group)
			if grade != tier: continue
			var weight: int = {4: 12, 5: 6, 6: 3, 7: 1}.get(rank, 12) if grade == 3 else 1
			result.append({"kind": pair[0], "id": row.id, "rarity": rank, "grade": grade, "weight": weight})
	return result

static func summon(store: ProgressStore, count: int = 1, use_ticket: bool = false) -> bool:
	if count not in [1, 10] or store.read_only or not store.profile.pending.is_empty() or (Supplies.count(store.profile,"normal_ticket")<count if use_ticket else store.profile.gold < PRICE * count): return false
	var p := store.profile.duplicate(true)
	ensure(store, p)
	if use_ticket: p.supplies.counts.normal_ticket -= count
	if p.recruitment.count > 2147483647 - count: return false
	for i in range(count):
		if not _draw(store, p,not use_ticket):
			store.error = "Your equipment bag is full. Dismantle or fuse items and try again; no Gold or tickets spent."
			return false
	p.recruitment["last_batch"] = {"end_count":p.recruitment.count, "entries":p.recruitment.history.slice(0,count).duplicate(true)}
	MissionBoard.record(p, "summon", count)
	return store.commit(p)

static func _draw(store: ProgressStore, p: Dictionary, pay_gold: bool = true) -> bool:
	var r: Dictionary = p.recruitment
	var rng := RandomNumberGenerator.new()
	rng.seed = int(r.seed) + int(r.count) * 7919
	var roll := rng.randi_range(0, 9999)
	var tier := 3 if r.pity >= 19 or roll >= 9500 else (2 if roll >= 7000 else 1)
	var candidates := pool(store.catalog, tier)
	var total := 0
	for entry in candidates: total += int(entry.weight)
	var choice := rng.randi_range(1, total)
	var reward: Dictionary = {}
	for entry in candidates:
		choice -= int(entry.weight)
		if choice <= 0:
			reward = entry.duplicate(true)
			break
	reward.erase("weight")
	reward["duplicate"] = false
	if pay_gold: p.gold -= PRICE
	match reward.kind:
		"item":
			if not store._add_item(p, reward.id): return false
		"hero":
			reward["duplicate"] = (store.available_hero(reward.id) or reward.id in r.heroes)
			if reward.id not in r.heroes: r.heroes.append(reward.id)
			if reward["duplicate"]: r.fragments[reward.id] += 10
		"spirit":
			reward["duplicate"] = (store.available_assist(reward.id) or reward.id in r.spirits)
			if reward.id not in r.spirits: r.spirits.append(reward.id)
			if reward["duplicate"]: p.collection_fragments.spirits[reward.id] += CollectionFragments.DUPLICATE_AMOUNT
	if reward["duplicate"]: reward["fragment_amount"] = CollectionFragments.DUPLICATE_AMOUNT
	r.count += 1
	r.pity = 0 if tier == 3 else r.pity + 1
	r.history.push_front(reward)
	if r.history.size() > HISTORY_LIMIT: r.history.pop_back()
	return true

static func awaken(store: ProgressStore, hero_id: String = "") -> bool:
	if store.read_only or not store.profile.pending.is_empty(): return false
	var p := store.profile.duplicate(true)
	ensure(store, p)
	var target: String = p.hero if hero_id.is_empty() else hero_id
	if not store.available_hero(target): return false
	var rank: int = p.recruitment.awakening[target]
	if rank >= 5 or p.heroes[target].level < rank * 10 or p.gold < rank * 200 or p.recruitment.fragments[target] < rank * 20: return false
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
