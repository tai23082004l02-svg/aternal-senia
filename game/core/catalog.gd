class_name GameCatalog
extends RefCounted

var data: Dictionary
var errors: Array[String] = []

func _init() -> void:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/catalog.json"))
	if not parsed is Dictionary:
		errors.append("Catalog không đọc được")
		return
	data = normalize(parsed)
	for group in ["heroes", "items", "skills", "stages", "quests", "assists"]:
		var ids: Array = []
		for row in data[group]:
			if row.id in ids:
				errors.append("ID trùng: %s" % row.id)
			ids.append(row.id)
	for row in data.skills:
		if row.cd <= 0 or row.hit > row.duration or row.power <= 0:
			errors.append("Kỹ năng không hợp lệ: " + row.id)
	for row in data.stages:
		for id in row.drops:
			if find_row("items", id).is_empty():
				errors.append("Drop thiếu: " + id)

func find_row(group: String, id: Variant) -> Dictionary:
	for row in data[group]:
		if (row.id is String and str(row.id) == str(id)) or ((row.id is float or row.id is int) and (id is float or id is int) and float(row.id) == float(id)):
			return row
	return {}

func category(hero_id: String) -> String:
	return {"eira": "sword", "ryn": "spear", "mira": "staff"}.get(hero_id, "sword")

func stats(profile: Dictionary, hero_id: String = "") -> Dictionary:
	if hero_id.is_empty():
		hero_id = profile.hero
	var base := find_row("heroes", hero_id)
	var unit: Dictionary = profile.heroes[hero_id]
	var result := {"hp": float(base.hp) + (unit.level - 1) * 25, "atk": float(base.atk) + (unit.level - 1) * 4, "defense": float(base.defense) + unit.level - 1, "crit": float(base.crit), "element": base.element, "skill_bonus": base.skill_bonus, "hero": hero_id, "assist": profile.assist, "assist_level": profile.assists[profile.assist], "skills": unit.skills.duplicate(), "weapon": category(hero_id) + "_1", "cooldown_scale": 1.0}
	for slot in ["weapon", "armor"]:
		var uid: String = unit.equipment[slot]
		for item in profile.items:
			if item.uid != uid:
				continue
			var def := find_row("items", item.base)
			var multiplier: float = 1.0 + item.enhance * 0.18 + (item.rank - 1) * 0.5
			for stat in ["hp", "atk", "defense"]:
				result[stat] += float(def[stat]) * multiplier
			if slot == "weapon":
				result.weapon = item.base
				result.element = def.element
				result.cooldown_scale = .92 if def.rarity >= 2 else 1.0
	return result

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
