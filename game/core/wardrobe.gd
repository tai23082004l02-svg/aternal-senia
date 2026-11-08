class_name Wardrobe
extends RefCounted

const LOOKS := {
	"original": {"name": "Original Outfit", "tint": Color.WHITE},
	"dawn": {"name": "Dawn Palette", "tint": Color(1, .9, .78, 1)},
	"moon": {"name": "Moonlight Palette", "tint": Color(.82, .9, 1, 1)}
}

static func fresh(book: GameCatalog = null) -> Dictionary:
	var result := {}
	var rows: Array = book.data.heroes if book != null else GameCatalog.new().data.heroes
	for hero in rows: result[hero.id] = "original"
	return result

static func selected(p: Dictionary, hero: String) -> String:
	return str(p.get("outfits", {}).get(hero, "original"))

static func tint(p: Dictionary, hero: String) -> Color:
	return LOOKS[selected(p, hero)].tint

static func valid(store: ProgressStore, p: Dictionary) -> bool:
	if not p.has("outfits"): return true
	if not p.outfits is Dictionary or p.outfits.size() != store.catalog.data.heroes.size(): return false
	for hero in store.catalog.data.heroes:
		if p.outfits.get(hero.id) not in LOOKS: return false
	return true

static func apply(store: ProgressStore, hero: String, look: String) -> bool:
	if look not in LOOKS or store.read_only or not store.profile.pending.is_empty() or not store.available_hero(hero): return false
	var p := store.profile.duplicate(true)
	if not p.has("outfits"): p.outfits = fresh(store.catalog)
	p.outfits[hero] = look
	return store.commit(p)
