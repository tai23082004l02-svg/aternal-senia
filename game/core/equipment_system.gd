class_name EquipmentSystem
extends RefCounted

const SLOTS := ["weapon", "armor", "boots", "accessory"]
const SLOT_NAMES := {"weapon": "Vũ khí", "armor": "Giáp", "boots": "Giày", "accessory": "Phụ kiện"}
const EFFECTS := ["radiance", "burn", "tide", "aegis"]
const MAX_ENHANCE := 15
const OLD_ITEMS := ["sword_1", "sword_2", "spear_1", "spear_2", "staff_1", "staff_2", "armor_1", "armor_2", "armor_3", "armor_uncommon", "armor_4", "armor_5", "armor_6", "armor_7"]

static func multiplier(item: Dictionary) -> float:
	return 1.0 + item.enhance * .18 + (item.rank - 1) * .5

static func item_for(p: Dictionary, uid: String) -> Dictionary:
	for item in p.items:
		if item.uid == uid: return item
	return {}

static func migrate(p: Dictionary, book: GameCatalog) -> void:
	for def in book.data.items:
		if not p.collection_fragments.items.has(def.id): p.collection_fragments.items[def.id] = 0
	for row in book.data.heroes:
		var equipment: Dictionary = p.heroes[row.id].equipment
		for slot in ["boots", "accessory"]:
			if not equipment.has(slot): equipment[slot] = ""
		var previous := item_for(p, equipment.armor)
		if not previous.is_empty() and previous.base == "armor_3":
			equipment.accessory = previous.uid
			equipment.armor = ""

static func set_counts(book: GameCatalog, p: Dictionary, hero: String) -> Dictionary:
	var counts := {}
	for slot in SLOTS:
		var item := item_for(p, p.heroes[hero].equipment.get(slot, ""))
		if item.is_empty(): continue
		var id: String = book.find_row("items", item.base).get("set_id", "")
		if not id.is_empty(): counts[id] = counts.get(id, 0) + 1
	return counts

static func apply(book: GameCatalog, p: Dictionary, hero: String, result: Dictionary) -> void:
	for key in ["haste", "dodge", "sp_regen", "damage_reduction"]: result[key] = 0.0
	result["gear_effects"] = []
	for slot in SLOTS:
		var item := item_for(p, p.heroes[hero].equipment[slot])
		if item.is_empty(): continue
		var def := book.find_row("items", item.base)
		result.haste += float(def.get("haste", 0))
		for key in def.get("secondary", {}): result[key] = float(result.get(key, 0)) + float(def.secondary[key])
		if not def.get("effect", "").is_empty() and def.rarity >= 5: result.gear_effects.append(def.effect)
	result["equipment_sets"] = set_counts(book, p, hero)
	for set_def in book.data.sets:
		for bonus in set_def.bonuses:
			if result.equipment_sets.get(set_def.id, 0) < bonus.pieces: continue
			for key in bonus.stats:
				var amount: float = bonus.stats[key]
				match key:
					"hp_pct": result.hp *= 1 + amount
					"atk_pct": result.atk *= 1 + amount
					"defense_pct": result.defense *= 1 + amount
					"skill_pct": result.skill_bonus *= 1 + amount
					_: result[key] = float(result.get(key, 0)) + amount
	result.crit = clampf(result.crit, 0, .75)
	result.haste = clampf(result.haste, 0, .3)
	result.dodge = clampf(result.dodge, 0, .25)
	result.sp_regen = clampf(result.sp_regen, 0, 3)
	result.damage_reduction = clampf(result.damage_reduction, 0, .25)

static func valid_snapshot(store: ProgressStore, snapshot: Dictionary) -> bool:
	for key in ["haste", "dodge", "sp_regen", "damage_reduction"]:
		var limit: float = {"haste": .3, "dodge": .25, "sp_regen": 3, "damage_reduction": .25}[key]
		if snapshot.has(key) and not store._number(snapshot[key], 0, limit): return false
	if snapshot.has("gear_effects"):
		if not snapshot.gear_effects is Array or not Expansion.unique(snapshot.gear_effects): return false
		for effect in snapshot.gear_effects:
			if effect not in EFFECTS: return false
	if snapshot.has("equipment_sets"):
		if not snapshot.equipment_sets is Dictionary: return false
		var total := 0
		for id in snapshot.equipment_sets:
			if store.catalog.find_row("sets", id).is_empty() or not store._whole(snapshot.equipment_sets[id], 1, 4): return false
			total += int(snapshot.equipment_sets[id])
		if total > 4: return false
	return true
