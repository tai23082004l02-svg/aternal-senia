class_name HeroContract
extends RefCounted

const FIELDS := ["weapon_category", "role", "gallery_order", "combat", "summon_group", "acquisition", "art", "skill_descriptions"]

# Only implemented mechanics are accepted. Planning affinities/weapons stay outside runtime.
static func valid_combat(value: Variant) -> bool:
	if not value is Dictionary: return false
	if value.get("basic") not in ["damage", "adaptive_heal"] or value.get("ultimate") not in ["damage", "team_heal"]: return false
	if not value.get("ultimate_shield") is bool: return false
	var multiplier = value.get("damage_taken")
	return (multiplier is float or multiplier is int) and is_finite(float(multiplier)) and multiplier > 0 and multiplier <= 1

static func valid(hero: Dictionary) -> bool:
	if hero.get("rarity") != 5 or hero.get("weapon_category") not in ["sword", "spear", "staff"]: return false
	if hero.get("element") not in ["light", "fire", "water", "nature", "dark"]: return false
	if hero.get("summon_group") not in [1,2,3] or not valid_combat(hero.get("combat")): return false
	if not hero.get("gallery_order") is int or not hero.get("role") is String or not hero.get("acquisition") is String: return false
	if not hero.get("art") is Dictionary or not hero.art.get("banner") is String or not ResourceLoader.exists(hero.art.banner): return false
	if not hero.get("skill_descriptions") is Dictionary: return false
	return hero.skill_descriptions.get("basic") is String and hero.skill_descriptions.get("ultimate") is String
