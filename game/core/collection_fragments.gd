class_name CollectionFragments
extends RefCounted

const DUPLICATE_AMOUNT := 10

static func fresh(book: GameCatalog) -> Dictionary:
	var result := {"items": {}, "spirits": {}}
	for row in book.data.items: result.items[row.id] = 0
	for row in book.data.assists: result.spirits[row.id] = 0
	return result

static func valid(store: ProgressStore, value: Variant, legacy: bool = false, previous_sets: bool = false) -> bool:
	if not value is Dictionary or value.size() != 2: return false
	var expected := fresh(store.catalog)
	if legacy:
		for id in expected.items.keys():
			if id not in EquipmentSystem.OLD_ITEMS: expected.items.erase(id)
	elif previous_sets:
		for id in expected.items.keys():
			if not EquipmentSystem.previous_item(store.catalog,id): expected.items.erase(id)
	for kind in expected:
		if not value.get(kind) is Dictionary or value[kind].size() != expected[kind].size(): return false
		for id in expected[kind]:
			if not store._whole(value[kind].get(id), 0, 1e12): return false
	return true

static func migrate(p: Dictionary, book: GameCatalog) -> void:
	# Only called after the complete legacy profile passes its former validation.
	p.collection_fragments = fresh(book)
	var retained := {}
	var aliases := {}
	var unique: Array = []
	for item in p.items:
		if not retained.has(item.base):
			retained[item.base] = item
			unique.append(item)
		else:
			var survivor: Dictionary = retained[item.base]
			# Keep the highest paid values even if they were on different copies.
			survivor.enhance = maxi(survivor.enhance, item.enhance)
			survivor.rank = maxi(survivor.rank, item.rank)
			p.collection_fragments.items[item.base] += DUPLICATE_AMOUNT
		aliases[item.uid] = retained[item.base].uid
	p.items = unique
	for row in book.data.heroes:
		var hero: Dictionary = p.heroes[row.id]
		for slot in ["weapon", "armor"]:
			var uid: String = hero.equipment[slot]
			if not uid.is_empty(): hero.equipment[slot] = aliases[uid]
	# Do not mutate pending.stats: an in-flight battle keeps its original build.

static func reward_suffix(entry: Dictionary) -> String:
	if not entry.get("duplicate", false): return ""
	if entry.has("fragment_amount"):
		return " · +%d mảnh %s" % [entry.fragment_amount, {"hero": "nhân vật", "spirit": "tinh linh", "item": "trang bị"}[entry.kind]]
	# Old history describes rewards actually paid by the old version.
	return " · +10 mảnh nhân vật" if entry.kind == "hero" else " · +2 lõi (lượt cũ)"
