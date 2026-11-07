class_name PlayerIdentity
extends RefCounted

# Paid VIP remains inactive until a verified payment service is configured.
const VIP_TIERS := 10

static func state(profile: Dictionary) -> Dictionary:
	return profile.get("identity", {"name": "Nhà lữ hành", "avatar": "eira"})

static func valid(store, profile: Dictionary) -> bool:
	if not profile.has("identity"): return true # Optional field for existing v5 saves.
	var value = profile.identity
	if not value is Dictionary or not value.get("name") is String or not value.get("avatar") is String: return false
	if not valid_name(value.name): return false
	return not store.catalog.find_row("heroes", value.avatar).is_empty()

static func valid_name(value: String) -> bool:
	if value != value.strip_edges() or value.length() < 1 or value.length() > 20: return false
	for i in range(value.length()):
		if value.unicode_at(i) < 32 or value.unicode_at(i) == 127: return false
	return true

static func save(store, display_name: String, avatar: String) -> bool:
	var clean := display_name.strip_edges()
	if not valid_name(clean) or not store.available_hero(avatar):
		store.error = "Tên cần 1–20 ký tự; avatar cần là nhân vật đã sở hữu."
		return false
	var candidate: Dictionary = store.profile.duplicate(true)
	candidate.identity = {"name": clean, "avatar": avatar}
	return store.commit(candidate)
