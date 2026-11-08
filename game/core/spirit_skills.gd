class_name SpiritSkills
extends RefCounted

const ADVANCED := {
	"echo": {"name": "Resonance", "description": "Spirits deal 15% more damage.", "level": 6},
	"aegis": {"name": "Protector", "description": "Spirit hits grant a 10% HP shield for 5 seconds.", "level": 6}
}

static func builds(p: Dictionary) -> Dictionary:
	if p.expansion.has("spirit_skills"):
		return p.expansion.spirit_skills
	# Preserve prior investment: both spirits inherit the highest old active-skill
	# level and all learned spirit branches. Pending snapshots are never changed.
	var level := 1
	var learned: Array = []
	for hero in p.heroes:
		level = maxi(level, int(p.heroes[hero].skills[2]))
		for id in p.expansion.builds[hero].learned:
			if id in ["nova", "flow"] and id not in learned: learned.append(id)
	var selected: String = p.expansion.builds[p.hero].selected[2]
	var result := {}
	for id in ["lumi", "ash"]:
		result[id] = {"level": level, "learned": learned.duplicate(), "selected": selected, "advanced_learned": [], "advanced": ""}
	return result

static func valid(store: ProgressStore, p: Dictionary) -> bool:
	if not p.expansion.has("spirit_skills"): return true
	var data = p.expansion.spirit_skills
	if not data is Dictionary or data.size() != 2: return false
	for id in ["lumi", "ash"]:
		var b = data.get(id)
		if not b is Dictionary or not store._whole(b.get("level"), 1, 10): return false
		for key in ["learned", "advanced_learned"]:
			if not b.get(key) is Array or not Expansion.unique(b[key]): return false
		for talent in b.learned:
			if talent not in ["nova", "flow"]: return false
		for talent in b.advanced_learned:
			if talent not in ADVANCED: return false
		if not b.get("selected") is String or not b.get("advanced") is String: return false
		if b.selected != "" and b.selected not in b.learned: return false
		if b.advanced != "" and (b.advanced not in b.advanced_learned or b.selected == ""): return false
	return true

static func ensure(p: Dictionary) -> void:
	if not p.expansion.has("spirit_skills"): p.expansion.spirit_skills = builds(p)

static func upgrade(store: ProgressStore) -> bool:
	if store.read_only or not store.profile.pending.is_empty(): return false
	var p := store.profile.duplicate(true)
	ensure(p)
	var b: Dictionary = p.expansion.spirit_skills[p.assist]
	if b.level >= 10 or p.gold < b.level * 25: return false
	p.gold -= b.level * 25
	b.level += 1
	return store.commit(p)

static func choose(store: ProgressStore, id: String) -> bool:
	if store.read_only or not store.profile.pending.is_empty(): return false
	var p := store.profile.duplicate(true)
	ensure(p)
	var b: Dictionary = p.expansion.spirit_skills[p.assist]
	var advanced := id in ADVANCED
	if not advanced and id not in ["nova", "flow"]: return false
	var row: Dictionary = ADVANCED[id] if advanced else store.catalog.find_row("talents", id)
	if p.assists[p.assist] < row.level or (advanced and b.selected == ""): return false
	var list: Array = b.advanced_learned if advanced else b.learned
	if id not in list:
		var gold := 100 if advanced else int(row.gold)
		var shards := 3 if advanced else int(row.shards)
		if p.gold < gold or p.shards < shards: return false
		p.gold -= gold
		p.shards -= shards
		list.append(id)
	var key := "advanced" if advanced else "selected"
	b[key] = "" if b[key] == id else id
	if b.selected == "": b.advanced = ""
	return store.commit(p)
