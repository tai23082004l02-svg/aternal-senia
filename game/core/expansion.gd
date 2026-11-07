class_name Expansion
extends RefCounted

static func fresh(book: GameCatalog) -> Dictionary:
	var builds := {}
	for hero in book.data.heroes:
		builds[hero.id] = {"learned": [], "selected": ["", "", ""]}
	return {"builds": builds, "ranks": {"lumi": 1, "ash": 1}, "cores": 0, "discovered": ["sword_1", "spear_1", "staff_1"], "records": {}, "claimed": []}

static func valid(store: ProgressStore, value: Variant) -> bool:
	if not value is Dictionary: return false
	for key in fresh(store.catalog):
		if not value.has(key): return false
	if not store._whole(value.cores, 0, 1e12) or not value.builds is Dictionary or not value.ranks is Dictionary or not value.records is Dictionary: return false
	for id in ["lumi", "ash"]:
		if not store._whole(value.ranks.get(id), 1, 3): return false
	for hero in store.catalog.data.heroes:
		var build = value.builds.get(hero.id)
		if not build is Dictionary or not build.get("learned") is Array or not build.get("selected") is Array or build.selected.size() != 3: return false
		if not unique(build.learned): return false
		for id in build.learned:
			if store.catalog.find_row("talents", id).is_empty(): return false
		for i in range(3):
			var id = build.selected[i]
			if id == "": continue
			var talent := store.catalog.find_row("talents", id)
			if id not in build.learned or talent.is_empty() or talent.slot != i: return false
	for key in ["discovered", "claimed"]:
		if not value[key] is Array or not unique(value[key]): return false
	for id in value.discovered:
		if store.catalog.find_row("items", id).is_empty(): return false
	for id in value.claimed:
		if store.catalog.find_row("achievements", id).is_empty(): return false
	for id in value.records:
		var row := store.catalog.find_row("stages", int(id))
		var record = value.records[id]
		if row.get("kind") != "challenge" or not record is Dictionary: return false
		if not store._whole(record.get("score"), 0, 10000) or not store._number(record.get("time"), 0, 1e8): return false
	return true

static func unique(values: Array) -> bool:
	var seen := {}
	for value in values:
		if not value is String or seen.has(value): return false
		seen[value] = true
	return true

static func stats(book: GameCatalog, profile: Dictionary, hero: String, result: Dictionary) -> void:
	var extra: Dictionary = profile.expansion
	result["variants"] = extra.builds[hero].selected.duplicate()
	result["assist_rank"] = extra.ranks[profile.assist]
	result["weapon_trait"] = ""
	for item in profile.items:
		if item.uid == profile.heroes[hero].equipment.weapon:
			result["weapon_trait"] = book.data.traits.get(item.base, {}).get("id", "")

static func talent(store: ProgressStore, id: String) -> bool:
	var row := store.catalog.find_row("talents", id)
	if row.is_empty() or not store.profile.pending.is_empty(): return false
	var p := store.profile.duplicate(true)
	var build: Dictionary = p.expansion.builds[p.hero]
	if row.level > p.heroes[p.hero].level: return false
	if id not in build.learned:
		if p.gold < row.gold or p.shards < row.shards: return false
		p.gold -= row.gold
		p.shards -= row.shards
		build.learned.append(id)
	build.selected[row.slot] = "" if build.selected[row.slot] == id else id
	return store.commit(p)

static func rank_up(store: ProgressStore) -> bool:
	if not store.profile.pending.is_empty(): return false
	var p := store.profile.duplicate(true)
	var rank: int = p.expansion.ranks[p.assist]
	var cost := rank * 80
	var cores := 2 if rank == 1 else 5
	if rank >= 3 or p.assists[p.assist] < rank * 3 or p.gold < cost or p.expansion.cores < cores: return false
	p.gold -= cost
	p.expansion.cores -= cores
	p.expansion.ranks[p.assist] += 1
	return store.commit(p)

static func metric(p: Dictionary, name: String) -> int:
	match name:
		"items": return p.expansion.discovered.size()
		"bosses", "branches":
			var count := 0
			for id in p.cleared:
				if (name == "bosses" and id <= 5) or (name == "branches" and id >= 6 and id <= 15): count += 1
			return count
		"ranks": return p.expansion.ranks.lumi + p.expansion.ranks.ash
		"score":
			var score := 0
			for record in p.expansion.records.values(): score += record.score
			return score
	return 0

static func claim(store: ProgressStore, id: String) -> bool:
	var row := store.catalog.find_row("achievements", id)
	if row.is_empty() or id in store.profile.expansion.claimed or metric(store.profile, row.metric) < row.target: return false
	var p := store.profile.duplicate(true)
	p.gold += row.gold
	p.shards += row.shards
	p.expansion.cores += row.cores
	p.expansion.claimed.append(id)
	return store.commit(p)

static func valid_snapshot(store: ProgressStore, snapshot: Dictionary) -> bool:
	var fields := ["variants", "assist_rank", "weapon_trait"]
	var present := 0
	for key in fields:
		if snapshot.has(key): present += 1
	if present == 0: return true # Legacy pending run: keep its original build.
	if present != 3 or not snapshot.variants is Array or snapshot.variants.size() != 3: return false
	if not store._whole(snapshot.assist_rank, 1, 3) or not snapshot.weapon_trait is String: return false
	var known := [""]
	for row in store.catalog.data.traits.values(): known.append(row.id)
	if snapshot.weapon_trait not in known: return false
	for i in range(3):
		if snapshot.variants[i] == "": continue
		var row := store.catalog.find_row("talents", snapshot.variants[i])
		if row.is_empty() or row.slot != i: return false
	return true
