class_name AttributeTraining
extends RefCounted

const ATTRIBUTES := {
	"hp": {"name": "Sinh lực", "bonus": 10.0},
	"atk": {"name": "Tấn công", "bonus": 1.5},
	"defense": {"name": "Phòng thủ", "bonus": .75}
}

static func fresh(book: GameCatalog) -> Dictionary:
	var result := {}
	for hero in book.data.heroes:
		result[hero.id] = {"hp": 0, "atk": 0, "defense": 0}
	return result

static func allocation(profile: Dictionary, hero: String) -> Dictionary:
	return profile.get("training", {}).get(hero, {"hp": 0, "atk": 0, "defense": 0})

static func remaining(profile: Dictionary, hero: String) -> int:
	var used := 0
	for value in allocation(profile, hero).values():
		used += int(value)
	return (int(profile.heroes[hero].level) - 1) * 2 - used

static func valid(store: ProgressStore, profile: Dictionary) -> bool:
	# Additive v3 field: existing profiles have an entirely unspent allocation.
	if not profile.has("training"):
		return true
	if not profile.training is Dictionary or profile.training.size() != store.catalog.data.heroes.size():
		return false
	for hero in store.catalog.data.heroes:
		var points = profile.training.get(hero.id)
		if not points is Dictionary or points.size() != ATTRIBUTES.size():
			return false
		for stat in ATTRIBUTES:
			if not store._whole(points.get(stat), 0, 198):
				return false
		if remaining(profile, hero.id) < 0:
			return false
	return true

static func apply(profile: Dictionary, hero: String, result: Dictionary) -> void:
	var points := allocation(profile, hero)
	for stat in ATTRIBUTES:
		result[stat] += points[stat] * ATTRIBUTES[stat].bonus

static func change(store: ProgressStore, stat: String, amount: int) -> bool:
	if stat not in ATTRIBUTES or amount not in [-1, 1] or store.read_only or not store.profile.pending.is_empty():
		return false
	var p := store.profile.duplicate(true)
	if not p.has("training"):
		p.training = fresh(store.catalog)
	var points: Dictionary = p.training[p.hero]
	if (amount == 1 and remaining(p, p.hero) <= 0) or (amount == -1 and points[stat] <= 0):
		return false
	points[stat] += amount
	return store.commit(p)

static func reset(store: ProgressStore) -> bool:
	if store.read_only or not store.profile.pending.is_empty():
		return false
	var p := store.profile.duplicate(true)
	if remaining(p, p.hero) == (int(p.heroes[p.hero].level) - 1) * 2:
		return false
	if not p.has("training"):
		p.training = fresh(store.catalog)
	p.training[p.hero] = {"hp": 0, "atk": 0, "defense": 0}
	return store.commit(p)
