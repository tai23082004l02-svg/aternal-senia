class_name Wardrobe
extends RefCounted

const LOOKS := {
	"original": {"name": "Trang phục gốc", "tint": Color.WHITE},
	"dawn": {"name": "Phối màu Bình minh", "tint": Color(1, .9, .78, 1)},
	"moon": {"name": "Phối màu Ánh trăng", "tint": Color(.82, .9, 1, 1)}
}

static func fresh() -> Dictionary:
	return {"eira": "original", "ryn": "original", "mira": "original"}

static func selected(p: Dictionary, hero: String) -> String:
	return p.get("outfits", fresh())[hero]

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
	if not p.has("outfits"): p.outfits = fresh()
	p.outfits[hero] = look
	return store.commit(p)
