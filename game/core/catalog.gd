class_name GameCatalog
extends RefCounted

var data: Dictionary
var errors: Array[String] = []

func _init() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/catalog.json"))
	if not parsed is Dictionary:
		errors.append("Unable to read the catalog")
		return
	data = normalize(parsed)
	var expansion: Dictionary = normalize(JSON.parse_string(FileAccess.get_file_as_string("res://game/data/expansion.json")))
	data.stages.append_array(expansion.stages)
	if FileAccess.file_exists("res://game/data/team_encounters.json"):
		var encounters = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/team_encounters.json"))
		if not encounters is Dictionary or not encounters.get("stages") is Dictionary:
			errors.append("Invalid 3vN data")
		else:
			for stage in data.stages:
				if encounters.stages.has(str(stage.id)): stage.team_encounter = normalize(encounters.stages[str(stage.id)])
	for key in ["talents", "traits", "achievements", "chapters"]:
		data[key] = expansion[key]
	for item in data.items:
		if item.get("rarity") not in [3, 4, 5, 6, 7]: errors.append("Invalid equipment rarity")
		if item.get("slot") not in EquipmentSystem.SLOTS: errors.append("Invalid equipment slot")
		if item.get("summon_group") not in [1, 2, 3]: errors.append("Invalid summon group")
		if not item.get("set_id", "").is_empty() and find_row("sets", item.set_id).is_empty(): errors.append("Invalid equipment set")
		if item.get("effect", "") not in [""] + EquipmentSystem.EFFECTS or (not item.get("effect", "").is_empty() and item.rarity < 5): errors.append("Invalid equipment effect")
		if data.traits.has(item.id): item.passive = data.traits[item.id].description
	for hero in data.heroes:
		if hero.get("rarity") not in [1, 2, 3, 4, 5]: errors.append("Invalid hero base rarity")
	for spirit in data.assists:
		if spirit.get("rarity") not in ["SR", "SSR", "UR"]: errors.append("Invalid spirit rarity")
	for opponent in data.opponents:
		if opponent.get("rarity") not in [1, 2, 3, 4]: errors.append("Invalid enemy rarity")
	for group in ["sets", "heroes", "items", "skills", "stages", "quests", "assists", "talents", "achievements", "chapters"]:
		var ids: Array = []
		for row in data[group]:
			if row.id in ids:
				errors.append("Duplicate ID: %s" % row.id)
			ids.append(row.id)
	for row in data.skills:
		if row.cd <= 0 or row.hit > row.duration or row.power <= 0:
			errors.append("Invalid skill: " + row.id)
	for row in data.stages:
		for id in row.drops:
			if find_row("items", id).is_empty():
				errors.append("Missing drop: " + id)

	for row in data.stages:
		for required in row.get("requires", []):
			if required == row.id or find_row("stages", required).is_empty(): errors.append("Invalid stage requirements")
		if row.has("waves"):
			if row.waves.is_empty() or row.waves.size() > 12: errors.append("Invalid wave count")
			for wave in row.waves:
				if wave.hp <= 0 or wave.atk <= 0 or wave.mechanic not in ["smash", "shield", "counter"]: errors.append("Invalid wave")
	for row in data.talents:
		if row.slot not in [0, 1, 2] or row.level < 2 or row.gold < 0 or row.shards < 0: errors.append("Invalid skill branch")

func find_row(group: String, id: Variant) -> Dictionary:
	for row in data[group]:
		if (row.id is String and str(row.id) == str(id)) or ((row.id is float or row.id is int) and (id is float or id is int) and float(row.id) == float(id)):
			return row
	return {}

func category(hero_id: String) -> String:
	return {"eira": "sword", "ryn": "spear", "lyra": "spear", "mira": "staff"}.get(hero_id, "sword")

func stats(profile: Dictionary, hero_id: String = "") -> Dictionary:
	if hero_id.is_empty():
		hero_id = profile.hero
	var base := find_row("heroes", hero_id)
	var unit: Dictionary = profile.heroes[hero_id]
	var result := {"hp": float(base.hp) + (unit.level - 1) * 25, "atk": float(base.atk) + (unit.level - 1) * 4, "defense": float(base.defense) + unit.level - 1, "crit": float(base.crit), "element": base.element, "skill_bonus": base.skill_bonus, "hero": hero_id, "assist": profile.assist, "assist_level": profile.assists[profile.assist], "skills": unit.skills.duplicate(), "weapon": category(hero_id) + "_1", "cooldown_scale": 1.0}
	for slot in EquipmentSystem.SLOTS:
		var uid: String = unit.equipment[slot]
		for item in profile.items:
			if item.uid != uid:
				continue
			var def := find_row("items", item.base)
			var multiplier := EquipmentSystem.multiplier(item)
			for stat in ["hp", "atk", "defense"]:
				result[stat] += float(def[stat]) * multiplier
			if slot == "weapon":
				result.weapon = item.base
				result.element = def.element
				result.cooldown_scale = def.cooldown_scale
	Expansion.stats(self, profile, hero_id, result)
	AttributeTraining.apply(profile, hero_id, result)
	var awakening: int = Recruitment.state(profile).awakening[hero_id] - 1
	result.hp += awakening * 30
	result.atk += awakening * 3
	result.defense += awakening
	EquipmentSystem.apply(self, profile, hero_id, result)
	var evolution_bonus := 1.0 + (HeroEvolution.rank(profile, hero_id) - 1) * .08
	for stat in ["hp", "atk", "defense"]: result[stat] *= evolution_bonus
	var look := Wardrobe.tint(profile, hero_id)
	result["look_tint"] = [look.r, look.g, look.b, look.a]
	return normalize(result)

static func normalize(value: Variant) -> Variant:
	if value is float and is_finite(value) and value == floor(value):
		return int(value)
	if value is Array:
		var result: Array = []
		for child in value:
			result.append(normalize(child))
		return result
	if value is Dictionary:
		var result := {}
		for key in value:
			result[key] = normalize(value[key])
		return result
	return value
