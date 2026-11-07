class_name Formation
extends RefCounted

static func state(p: Dictionary, book: GameCatalog) -> Dictionary:
	if p.has("formation"): return p.formation
	var slots: Array = [p.hero]
	for hero in book.data.heroes:
		if slots.size() >= 3: break
		if hero.id not in slots and owned(book, p, hero.id): slots.append(hero.id)
	while slots.size() < 3: slots.append("")
	return {"slots":slots, "auto_ult":true, "auto_next":false}

static func owned(book: GameCatalog, p: Dictionary, id: String) -> bool:
	var row := book.find_row("heroes", id)
	var highest := 1
	for stage in p.cleared:
		if stage <= 5: highest = maxi(highest, int(stage) + 1)
	return not row.is_empty() and (row.unlock <= mini(5, highest) or id in Recruitment.state(p).heroes)

static func valid(store, p: Dictionary) -> bool:
	if not p.has("formation"): return true
	var f = p.formation
	if not f is Dictionary or not f.get("slots") is Array or f.slots.size() != 3: return false
	if not f.get("auto_ult") is bool or not f.get("auto_next") is bool: return false
	var seen := []
	for id in f.slots:
		if not id is String: return false
		if id.is_empty(): continue
		if id in seen or not owned(store.catalog, p, id): return false
		seen.append(id)
	return not seen.is_empty() and p.hero == seen[0]

static func assign(store, slot: int, id: String) -> bool:
	if slot < 0 or slot > 2 or store.read_only or not store.profile.pending.is_empty(): return false
	if not id.is_empty() and not store.available_hero(id): return false
	var p: Dictionary = store.profile.duplicate(true)
	p.formation = state(p, store.catalog).duplicate(true)
	var old: String = p.formation.slots[slot]
	var previous: int = p.formation.slots.find(id) if not id.is_empty() else -1
	if previous >= 0: p.formation.slots[previous] = old
	p.formation.slots[slot] = id
	var selected := ""
	for hero in p.formation.slots:
		if not hero.is_empty():
			selected = hero
			break
	if selected.is_empty(): return false
	p.hero = selected
	return store.commit(p)

static func option(store, key: String, enabled: bool) -> bool:
	if key not in ["auto_ult", "auto_next"] or store.read_only or not store.profile.pending.is_empty(): return false
	var p: Dictionary = store.profile.duplicate(true)
	p.formation = state(p, store.catalog).duplicate(true)
	p.formation[key] = enabled
	return store.commit(p)

static func snapshot(book: GameCatalog, p: Dictionary, stage: Dictionary) -> Dictionary:
	var units := []
	var f := state(p, book)
	for slot in range(3):
		var id: String = f.slots[slot]
		if id.is_empty(): continue
		units.append({"slot":slot, "stats":book.stats(p, id)})
	return GameCatalog.normalize({"version":1, "units":units, "assist":p.assist, "auto_ult":f.auto_ult, "auto_next":f.auto_next, "encounter":encounter(stage)})

static func encounter(stage: Dictionary) -> Dictionary:
	if stage.has("team_encounter"): return stage.team_encounter.duplicate(true)
	var definitions := []
	var base: int = stage.get("base_stage", stage.id)
	var boss_type: String = ["golem","guardian","mirror","bird","sentinel"][clampi(base - 1, 0, 4)]
	var source: Array = stage.get("waves", [{"boss":false}, {"boss":false}, {"boss":true}])
	for i in range(source.size()):
		var row: Dictionary = source[i]
		var boss: bool = row.boss
		var count := 1 if boss else (mini(2, i + 1) if stage.id == 1 else 3)
		var units := []
		for j in range(count):
			var elite: bool = not boss and i == 1 and j == 0 and stage.id != 1
			var health: float = row.get("hp", stage.boss_hp if boss else stage.enemy_hp * (1 + i * .35))
			var atk: float = row.get("atk", stage.boss_atk if boss else stage.enemy_atk)
			units.append({"type":row.get("enemy_type", boss_type if boss else ("wolf" if j == 0 and i > 0 else "slime")), "name":row.get("name", stage.boss) if boss else ("Tinh anh" if elite else ("Sói rừng" if j == 0 and i > 0 else "Slime")), "hp":health * (1.5 if elite else 1.0), "atk":atk * (1.15 if elite else 1.0), "boss":boss, "elite":elite, "mechanic":row.get("mechanic", stage.mechanic), "element":row.get("element", stage.element)})
		definitions.append({"units":units, "summon_adds":boss and stage.id != 1, "adds_hp":maxf(20, stage.enemy_hp * .7), "adds_atk":maxf(4, stage.enemy_atk * .65)})
	return {"waves":definitions, "limit":180, "important":stage.id <= 5 or stage.get("kind", "") == "challenge"}

static func kill_cap(encounter_data: Dictionary) -> int:
	var total := 0
	for wave in encounter_data.waves: total += wave.units.size() + (2 if wave.summon_adds else 0)
	return total

static func valid_snapshot(store, team: Variant) -> bool:
	if not team is Dictionary or team.get("version") != 1 or not team.get("units") is Array or team.units.is_empty() or team.units.size() > 3: return false
	if not team.get("auto_ult") is bool or not team.get("auto_next") is bool or store.catalog.find_row("assists", team.get("assist")).is_empty(): return false
	var ids := []
	var slots := []
	for unit in team.units:
		if not unit is Dictionary or not store._whole(unit.get("slot"), 0, 2) or unit.slot in slots or not unit.get("stats") is Dictionary: return false
		var s: Dictionary = unit.stats
		if store.catalog.find_row("heroes", s.get("hero")).is_empty() or s.hero in ids or s.get("assist") != team.assist: return false
		for key in ["hp", "atk", "defense", "crit", "skill_bonus", "assist_level"]:
			if not store._number(s.get(key), 0, 1e8): return false
		if s.hp <= 0 or s.atk <= 0 or not s.get("skills") is Array or s.skills.size() != 3: return false
		for level in s.skills:
			if not store._whole(level, 1, 10): return false
		if store.catalog.find_row("items", s.get("weapon")).is_empty() or not Expansion.valid_snapshot(store, s): return false
		ids.append(s.hero)
		slots.append(unit.slot)
	var e = team.get("encounter")
	if not e is Dictionary or not store._whole(e.get("limit"), 30, 600) or not e.get("important") is bool or not e.get("waves") is Array or e.waves.is_empty() or e.waves.size() > 10: return false
	for wave in e.waves:
		if not wave is Dictionary or not wave.get("units") is Array or wave.units.is_empty() or wave.units.size() > 4 or not wave.get("summon_adds") is bool: return false
		for field in ["adds_hp", "adds_atk"]:
			if not store._number(wave.get(field), 1, 1e8): return false
		for enemy in wave.units:
			if not enemy is Dictionary or enemy.get("type") not in ["slime","wolf","golem","guardian","mirror","bird","sentinel"] or not enemy.get("name") is String or not enemy.get("boss") is bool or not enemy.get("elite") is bool: return false
			for field in ["hp", "atk"]:
				if not store._number(enemy.get(field), 1, 1e8): return false
			if enemy.get("mechanic") not in ["smash","shield","counter"] or enemy.get("element") not in ["fire","water","nature","light","dark"]: return false
	return true
