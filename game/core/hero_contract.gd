class_name HeroContract
extends RefCounted

const FIELDS := ["weapon_category", "role", "gallery_order", "combat", "summon_group", "acquisition", "art", "skill_descriptions", "summon_enabled", "starter_weapon", "fragment_source"]

# Only implemented mechanics are accepted. Planning affinities/weapons stay outside runtime.
static func valid_combat(value: Variant) -> bool:
	if not value is Dictionary: return false
	if value.get("basic") not in ["damage", "adaptive_heal", "ember_guard", "shield_ally"] or value.get("ultimate") not in ["damage", "team_heal", "team_barrier", "execute"]: return false
	if not value.get("ultimate_shield") is bool: return false
	for key in ["basic_cooldown", "execute_threshold", "execute_multiplier", "guard_aura"]:
		if not value.has(key): continue
		var n = value[key]
		if not (n is float or n is int) or not is_finite(float(n)): return false
		var limits: Array = {"basic_cooldown":[.1,10],"execute_threshold":[.01,1],"execute_multiplier":[1,2],"guard_aura":[0,.5]}[key]
		if n < limits[0] or n > limits[1]: return false
	if value.get("ultimate") == "execute" and (not value.has("execute_threshold") or not value.has("execute_multiplier")): return false
	var multiplier = value.get("damage_taken")
	return (multiplier is float or multiplier is int) and is_finite(float(multiplier)) and multiplier > 0 and multiplier <= 1

static func art_texture(hero: Dictionary, purpose: String) -> Texture2D:
	var source: Texture2D = load(hero.art.banner)
	var rect: Array = hero.art.get(purpose + "_region", [])
	if rect.size() != 4: return source
	var region := AtlasTexture.new()
	region.atlas = source
	region.region = Rect2(rect[0],rect[1],rect[2],rect[3])
	region.filter_clip = true
	return region

static func valid(hero: Dictionary) -> bool:
	for flag in ["summon_enabled","starter_weapon"]:
		if hero.has(flag) and not hero[flag] is bool: return false
	if hero.get("rarity") != 5 or hero.get("weapon_category") not in ["sword", "spear", "staff"]: return false
	if hero.get("element") not in ["light", "fire", "water", "nature", "dark"]: return false
	if hero.get("summon_group") not in [1,2,3] or not valid_combat(hero.get("combat")): return false
	if not hero.get("gallery_order") is int or not hero.get("role") is String or not hero.get("acquisition") is String: return false
	if not hero.get("art") is Dictionary or not hero.art.get("banner") is String or not ResourceLoader.exists(hero.art.banner): return false
	if not hero.get("skill_descriptions") is Dictionary: return false
	return hero.skill_descriptions.get("basic") is String and hero.skill_descriptions.get("ultimate") is String
