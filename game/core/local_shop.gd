class_name LocalShop
extends RefCounted

const OFFERS := {
	"xp": {"name": "Sách kinh nghiệm", "gold": 100, "xp": 50, "shards": 0},
	"shards": {"name": "Túi tinh thạch", "gold": 120, "xp": 0, "shards": 3}
}

static func buy(store: ProgressStore, id: String) -> bool:
	if id not in OFFERS or store.read_only or not store.profile.pending.is_empty(): return false
	var offer: Dictionary = OFFERS[id]
	if store.profile.gold < offer.gold: return false
	var p := store.profile.duplicate(true)
	p.gold -= offer.gold
	p.xp += offer.xp
	p.shards += offer.shards
	return store.commit(p)
