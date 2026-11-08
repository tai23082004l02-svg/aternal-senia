class_name HeroEvolution
extends RefCounted

static func fresh(book: GameCatalog = null) -> Dictionary:
	var result := {}
	var rows: Array = book.data.heroes if book != null else GameCatalog.new().data.heroes
	for hero in rows: result[hero.id] = 1
	return result

static func rank(p: Dictionary, hero: String) -> int:
	return int(p.get("evolution", {}).get(hero, 1))

static func valid(store: ProgressStore, p: Dictionary) -> bool:
	if not p.has("evolution"): return true
	if not p.evolution is Dictionary or p.evolution.size() != store.catalog.data.heroes.size(): return false
	for hero in store.catalog.data.heroes:
		if not store._whole(p.evolution.get(hero.id), 1, 3): return false
	return true

static func eligible(store: ProgressStore, hero: String) -> bool:
	if not store.available_hero(hero): return false
	var p: Dictionary = store.profile
	var tier := rank(p, hero)
	return store.available_hero(hero) and tier < 3 and p.heroes[hero].level >= tier * 15 and Recruitment.state(p).awakening[hero] >= tier + 1 and p.gold >= tier * 250 and p.shards >= tier * 10 and p.expansion.cores >= tier * 3

static func evolve(store: ProgressStore, hero: String) -> bool:
	if store.read_only or not store.profile.pending.is_empty() or not store.available_hero(hero): return false
	if not eligible(store, hero): return false
	var p := store.profile.duplicate(true)
	var tier := rank(p, hero)
	if not p.has("evolution"): p.evolution = fresh(store.catalog)
	p.gold -= tier * 250
	p.shards -= tier * 10
	p.expansion.cores -= tier * 3
	p.evolution[hero] += 1
	return store.commit(p)
