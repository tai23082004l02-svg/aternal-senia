class_name ProgressStore
extends RefCounted

const VERSION = 11
const BAG_CAP = 40
var catalog: GameCatalog
var profile: Dictionary
var path: String
var error := ""
var read_only := false
var fail_writes := false # Fault injection for regression tests.

func _init(book: GameCatalog, save_path: String = "") -> void:
	catalog = book
	path = save_path if not save_path.is_empty() else "user://first_light_v2.json"
	var override_dir := OS.get_environment("FIRST_LIGHT_SAVE_DIR")
	if save_path.is_empty() and not override_dir.is_empty():
		DirAccess.make_dir_recursive_absolute(override_dir)
		path = override_dir.path_join("first_light_v2.json")
	profile = fresh()
	load_profile()

func fresh() -> Dictionary:
	var units := {}
	for hero in catalog.data.heroes:
		units[hero.id] = {"level": 1, "skills": [1, 1, 1], "equipment": {"weapon": "starter_" + hero.id, "armor": "", "boots": "", "accessory": ""}}
	var bag: Array = []
	var starters := {}
	for hero in catalog.data.heroes:
		var base := catalog.category(hero.id) + "_1"
		if not starters.has(base):
			starters[base] = "starter_" + hero.id
			bag.append({"uid": starters[base], "base": base, "enhance": 0, "rank": 1})
		units[hero.id].equipment.weapon = starters[base]
	return {"bag_rewards": [], "collection_fragments": CollectionFragments.fresh(catalog), "expansion": Expansion.fresh(catalog), "version": VERSION, "gold": 0, "shards": 0, "xp": 0, "hero": "eira", "assist": "lumi", "heroes": units, "assists": {"lumi": 1, "ash": 1}, "items": bag, "next_uid": 1, "cleared": [], "claimed": [], "metrics": {"wins": 0, "kills": 0, "enhances": 0, "clears": 0}, "seen_story": [], "last_offline": int(Time.get_unix_time_from_system()), "pending": {}, "settled": [], "settings": {"speed": 1, "sound": true}}

func valid(p: Variant, legacy_version: int = 0) -> bool:
	if not p is Dictionary or p.get("version") != (legacy_version if legacy_version > 0 else VERSION):
		return false
	for key in fresh():
		if legacy_version == 6 and key == "collection_fragments": continue
		if legacy_version in [6,7,8,9] and key == "bag_rewards": continue
		if not p.has(key):
			return false
	for key in ["gold", "shards", "xp", "next_uid", "last_offline"]:
		if not _whole(p[key], 0, 1e12):
			return false
	if not p.hero is String or catalog.find_row("heroes", p.hero).is_empty() or catalog.find_row("assists", p.assist).is_empty():
		return false
	if not p.heroes is Dictionary or not p.assists is Dictionary or not p.items is Array or p.items.size() > BAG_CAP:
		return false
	if legacy_version != 6 and not CollectionFragments.valid(self, p.collection_fragments, legacy_version in [7, 8],legacy_version in [9,10]): return false
	if legacy_version in [0,10]:
		if not p.bag_rewards is Array or p.bag_rewards.size() > 128: return false
		for base in p.bag_rewards:
			if not base is String or catalog.find_row("items", base).is_empty(): return false
			if legacy_version == 10 and not EquipmentSystem.previous_item(catalog,base): return false
	var bases: Array = []
	var uids: Array = []
	for item in p.items:
		if not item is Dictionary or not item.get("uid") is String or item.uid.is_empty() or item.uid in uids:
			return false
		if legacy_version in [6, 7, 8] and item.get("base") not in EquipmentSystem.OLD_ITEMS: return false
		if legacy_version in [9,10] and not EquipmentSystem.previous_item(catalog,item.get("base", "")): return false
		if catalog.find_row("items", item.get("base")).is_empty() or not _whole(item.get("enhance"), 0, 10 if legacy_version in [6, 7, 8] else EquipmentSystem.MAX_ENHANCE) or not _whole(item.get("rank"), 1, 3):
			return false
		if legacy_version in [7, 8, 9] and item.base in bases: return false
		bases.append(item.base)
		uids.append(item.uid)
	for hero in catalog.data.heroes:
		var unit = p.heroes.get(hero.id)
		if not unit is Dictionary or not _whole(unit.get("level"), 1, 100) or not unit.get("skills") is Array or unit.skills.size() != 3 or not unit.get("equipment") is Dictionary:
			return false
		for lv in unit.skills:
			if not _whole(lv, 1, 10):
				return false
		for slot in (["weapon", "armor"] if legacy_version in [6, 7, 8] else EquipmentSystem.SLOTS):
			var uid = unit.equipment.get(slot)
			if not uid is String:
				return false
			if uid.is_empty():
				continue
			if uid not in uids:
				return false
			var item: Dictionary = p.items[uids.find(uid)]
			var def := catalog.find_row("items", item.base)
			if ("armor" if legacy_version in [6, 7, 8] and item.base == "armor_3" else def.slot) != slot or (slot == "weapon" and def.category != catalog.category(hero.id)):
				return false
	for id in ["lumi", "ash"]:
		if not _whole(p.assists.get(id), 1, 20):
			return false
	for key in ["cleared", "claimed", "seen_story", "settled"]:
		if not p[key] is Array:
			return false
	for id in p.cleared:
		if catalog.find_row("stages", id).is_empty():
			return false
	for id in p.claimed:
		if catalog.find_row("quests", id).is_empty():
			return false
	if not p.metrics is Dictionary or not p.pending is Dictionary or not p.settings is Dictionary:
		return false
	for metric in ["wins", "kills", "enhances", "clears"]:
		if not _whole(p.metrics.get(metric), 0, 1e12):
			return false
	if not p.pending.is_empty():
		if not p.pending.get("id") is String or not _number(p.pending.get("seed"), 0, 1e12) or catalog.find_row("stages", p.pending.get("stage")).is_empty():
			return false
		var snapshot = p.pending.get("stats")
		if not snapshot is Dictionary:
			return false
		for key in ["hp", "atk", "defense", "crit", "skill_bonus", "assist_level"]:
			if not _number(snapshot.get(key), 0, 1e8):
				return false
		if not Expansion.valid_snapshot(self, snapshot): return false
		if snapshot.hp <= 0 or snapshot.atk <= 0 or not snapshot.get("skills") is Array or snapshot.skills.size() != 3:
			return false
		if catalog.find_row("heroes", snapshot.get("hero")).is_empty() or catalog.find_row("assists", snapshot.get("assist")).is_empty():
			return false
		for skill_level in snapshot.skills:
			if not _whole(skill_level, 1, 10):
				return false
		if catalog.find_row("items", snapshot.get("weapon")).is_empty():
			return false
	for key in ["sfx_volume", "ambience_volume", "music_volume"]:
		if p.settings.has(key) and not _number(p.settings[key], 0, 1):
			return false
	if not GameOptions.valid(p.settings): return false
	if not Expansion.valid(self, p.get("expansion")): return false
	if not AttributeTraining.valid(self, p): return false
	if not SpiritSkills.valid(self, p) or not Recruitment.valid(self, p): return false
	if not HeroEvolution.valid(self, p): return false
	if not Wardrobe.valid(self, p): return false
	if not PlayerIdentity.valid(self, p): return false
	if not MissionBoard.valid(self, p): return false
	if not Formation.valid(self, p): return false
	if not p.pending.is_empty() and p.pending.has("team"):
		if not Formation.valid_snapshot(self, p.pending.team): return false
		if p.pending.stats != p.pending.team.units[0].stats: return false
	return p.settings.get("speed") in [1, 2, 3] and p.settings.get("sound") is bool

func _number(value: Variant, low: float, high: float) -> bool:
	return (value is float or value is int) and is_finite(float(value)) and float(value) >= low and float(value) <= high

func load_profile() -> void:
	if FileAccess.file_exists(path):
		var raw = _decode(path)
		if raw is Dictionary and _number(raw.get("version"), VERSION + 1, 1e12):
			read_only = true
			error = "Save thuộc phiên bản mới hơn. Giữ nguyên file; cần cập nhật game."
			return
		if valid(raw):
			profile = raw
			return
		var backup = _decode(path + ".bak") if FileAccess.file_exists(path + ".bak") else null
		if valid(backup):
			var preserved := path + ".corrupt." + str(Time.get_ticks_usec())
			if DirAccess.copy_absolute(path, preserved) == OK:
				profile = backup
				error = "Đã đọc bản sao lưu; save lỗi được giữ riêng."
				return
		read_only = true
		error = "Save không hợp lệ. Không ghi đè; hãy giữ file để phục hồi."
		return
	# One-way migration; v1 is left untouched.
	var legacy_path := path.get_base_dir().path_join("first_light_v1.json")
	if FileAccess.file_exists(legacy_path):
		var legacy = _decode(legacy_path)
		if not legacy is Dictionary or legacy.get("version") != 1 or not _number(legacy.get("gold"), 0, 1e12) or not _number(legacy.get("level"), 1, 100):
			read_only = true
			error = "Save v1 không hợp lệ; giữ nguyên để phục hồi."
			return
		profile.gold = legacy.gold
		profile.heroes.eira.level = legacy.level
	commit(profile)

func commit(candidate: Dictionary) -> bool:
	if read_only or fail_writes:
		error = "Không ghi được tiến trình; tài nguyên chưa bị trừ."
		return false
	if not valid(candidate):
		error = "Giao dịch không hợp lệ."
		return false
	var temp := path + ".tmp"
	var file := FileAccess.open(temp, FileAccess.WRITE)
	if file == null:
		error = "Không mở được file lưu."
		return false
	file.store_string(JSON.stringify(candidate, "", true, true))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK or not valid(_decode(temp)):
		error = "Kiểm tra file lưu thất bại."
		return false
	if FileAccess.file_exists(path):
		var current = _decode(path)
		if valid(current) and DirAccess.copy_absolute(path, path + ".bak") != OK:
			error = "Không tạo được bản sao lưu."
			return false
	if DirAccess.rename_absolute(temp, path) != OK:
		error = "Không thay được file lưu."
		return false
	profile = candidate.duplicate(true)
	error = ""
	return true

func unlocked_stage() -> int:
	var highest := 1
	for id in profile.cleared:
		if id <= 5: highest = maxi(highest, int(id) + 1)
	return mini(5, highest)

func available_hero(id: String) -> bool:
	var row := catalog.find_row("heroes", id)
	return not row.is_empty() and (row.unlock <= unlocked_stage() or id in Recruitment.state(profile).heroes)

func available_assist(id: String) -> bool:
	var row := catalog.find_row("assists", id)
	return not row.is_empty() and (row.unlock <= unlocked_stage() or id in Recruitment.state(profile).spirits)

func change_hero(id: String) -> bool:
	if not available_hero(id) or not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	p.hero = id
	if p.has("formation"):
		var previous: int = p.formation.slots.find(id)
		if previous >= 0: p.formation.slots[previous] = p.formation.slots[0]
		p.formation.slots[0] = id
	return commit(p)

func change_assist(id: String) -> bool:
	if not available_assist(id) or not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	p.assist = id
	return commit(p)

func upgrade(kind: String, index: int = 0, hero_id: String = "") -> bool:
	if kind == "skill" and index == 2: return SpiritSkills.upgrade(self)
	if not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	var target: String = p.hero if hero_id.is_empty() else hero_id
	if not available_hero(target): return false
	var unit: Dictionary = p.heroes[target]
	var cost := 0
	var xp_cost := 0
	match kind:
		"hero":
			if unit.level >= 100:
				return false
			cost = int(unit.level) * 30
			xp_cost = int(unit.level) * 15
			unit.level += 1
		"skill":
			if index < 0 or index > 2 or unit.skills[index] >= 10:
				return false
			cost = int(unit.skills[index]) * 25
			unit.skills[index] += 1
		"assist":
			if p.assists[p.assist] >= 20:
				return false
			cost = int(p.assists[p.assist]) * 35
			p.assists[p.assist] += 1
		_:
			return false
	if p.gold < cost or p.xp < xp_cost:
		return false
	p.gold -= cost
	p.xp -= xp_cost
	return commit(p)

func equip(uid: String, hero_id: String = "") -> bool:
	if not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	var target: String = p.hero if hero_id.is_empty() else hero_id
	if not available_hero(target): return false
	for item in p.items:
		if item.uid != uid:
			continue
		var def := catalog.find_row("items", item.base)
		if def.slot == "weapon" and def.category != catalog.category(target):
			return false
		p.heroes[target].equipment[def.slot] = uid
		return commit(p)
	return false

func unequip(uid: String, hero_id: String = "") -> bool:
	if not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	var target: String = p.hero if hero_id.is_empty() else hero_id
	if not available_hero(target): return false
	for slot in EquipmentSystem.SLOTS:
		if p.heroes[target].equipment[slot] == uid:
			p.heroes[target].equipment[slot] = ""
			return commit(p)
	return false

func enhance(uid: String, rank_up: bool = false) -> bool:
	if not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	for item in p.items:
		if item.uid != uid:
			continue
		var cost := (int(item.rank) * 80) if rank_up else (int(item.enhance) + 1) * 20
		var shards := int(item.rank) * 4 if rank_up else 1
		if p.gold < cost or p.shards < shards or (rank_up and item.rank >= 3) or (not rank_up and item.enhance >= EquipmentSystem.MAX_ENHANCE):
			return false
		p.gold -= cost
		p.shards -= shards
		if rank_up:
			item.rank += 1
		else:
			item.enhance += 1
		p.metrics.enhances += 1
		MissionBoard.record(p, "enhance")
		return commit(p)
	return false

func forge(base: String, count: int = 1) -> bool:
	if count < 1 or count > 10 or catalog.find_row("items", base).get("summon_only", false): return false
	if not profile.pending.is_empty() or catalog.find_row("items", base).is_empty() or profile.items.size()+count > BAG_CAP or profile.gold < 65*count or profile.shards < 3*count:
		return false
	var p := profile.duplicate(true)
	p.gold -= 65*count
	p.shards -= 3*count
	for i in range(count):
		if not _add_item(p, base): return false
	return commit(p)

func fusion_donors(uid: String) -> Array:
	var target := EquipmentSystem.item_for(profile, uid)
	var donors := []
	if target.is_empty() or target.rank >= 3: return donors
	for item in profile.items:
		if item.uid == uid or item.base != target.base or item.rank != target.rank or item.enhance != 0: continue
		var equipped := false
		for hero in profile.heroes.values():
			if item.uid in hero.equipment.values(): equipped = true
		if not equipped: donors.append(item.uid)
		if donors.size() == 2: break
	return donors

func fuse(uid: String, expected_donors: Array) -> bool:
	if read_only or not profile.pending.is_empty() or expected_donors.size() != 2 or fusion_donors(uid) != expected_donors: return false
	var p := profile.duplicate(true)
	var target := EquipmentSystem.item_for(p, uid)
	if target.is_empty() or target.rank >= 3: return false
	p.items = p.items.filter(func(item): return item.uid not in expected_donors)
	target.rank += 1
	return commit(p)

func claim_bag_rewards() -> bool:
	if read_only or not profile.pending.is_empty() or profile.bag_rewards.is_empty() or profile.items.size() >= BAG_CAP: return false
	var p := profile.duplicate(true)
	while not p.bag_rewards.is_empty() and p.items.size() < BAG_CAP:
		var base: String = p.bag_rewards.pop_front()
		if not _add_item(p, base): return false
	return commit(p)

func dismantle(uid: String) -> bool:
	if not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	for hero in p.heroes:
		if uid in p.heroes[hero].equipment.values():
			return false
	for i in range(p.items.size()):
		if p.items[i].uid == uid:
			p.shards += 1 + int(p.items[i].rank)
			p.items.remove_at(i)
			return commit(p)
	return false

func dismantle_many(uids: Array) -> bool:
	if read_only or not profile.pending.is_empty() or uids.is_empty() or not Expansion.unique(uids): return false
	var p := profile.duplicate(true)
	for uid in uids:
		var item := EquipmentSystem.item_for(p, uid)
		if item.is_empty(): return false
		for hero in p.heroes.values():
			if uid in hero.equipment.values(): return false
		p.shards += 1 + int(item.rank)
	p.items = p.items.filter(func(item): return item.uid not in uids)
	return commit(p)

func upgrade_assist(id: String) -> bool:
	if read_only or not profile.pending.is_empty() or not available_assist(id) or profile.assists[id] >= 20: return false
	var p := profile.duplicate(true)
	var cost := int(p.assists[id])*35
	if p.gold < cost: return false
	p.gold -= cost
	p.assists[id] += 1
	return commit(p)

func _add_item(p: Dictionary, base: String) -> bool:
	if p.items.size() >= BAG_CAP or catalog.find_row("items", base).is_empty(): return false
	if base not in p.expansion.discovered: p.expansion.discovered.append(base)
	var used := []
	for item in p.items: used.append(item.uid)
	while "item_%d" % int(p.next_uid) in used: p.next_uid += 1
	p.items.append({"uid": "item_%d" % int(p.next_uid), "base": base, "enhance": 0, "rank": 1})
	p.next_uid += 1
	return true

func begin_run(stage_id: int, team_options: Dictionary = {}) -> bool:
	if not profile.pending.is_empty() or not can_enter(stage_id) or profile.bag_rewards.size() >= 128:
		return false
	var p := profile.duplicate(true)
	p.pending = {"id": "%d_%d" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()], "stage": stage_id, "seed": randi_range(1, 2147483646), "stats": catalog.stats(p)}
	p.pending.team = Formation.snapshot(catalog, p, catalog.find_row("stages", stage_id))
	for key in ["auto_ult", "auto_next"]:
		if team_options.has(key):
			if not team_options[key] is bool: return false
			p.pending.team[key] = team_options[key]
	return commit(p)

func settle(run_id: String, won: bool, kills: int, elapsed: float = 0) -> bool:
	if not _whole(kills, 0, 100) or not _number(elapsed, 0, 1e8): return false
	if run_id in profile.settled:
		return true
	if profile.pending.is_empty() or profile.pending.id != run_id:
		return false
	var p := profile.duplicate(true)
	var run: Dictionary = p.pending
	var stage := catalog.find_row("stages", run.stage)
	var max_kills: int = Formation.kill_cap(run.team.encounter) if run.has("team") else stage.get("waves", [0, 0, 0]).size()
	p.metrics.kills += clampi(kills, 0, max_kills)
	MissionBoard.record(p, "kills", clampi(kills, 0, max_kills))
	if won:
		p.gold += stage.gold
		p.xp += stage.xp
		p.shards += 2
		if run.stage not in p.cleared:
			p.gold += stage.first_gold
			p.cleared.append(run.stage)
			p.metrics.clears = Expansion.metric(p, "bosses")
		if stage.get("kind") == "challenge":
			p.expansion.cores += stage.cores
			var score := kills * 100 + maxi(0, 300 - int(elapsed * 3))
			var key := str(run.stage)
			var previous: Dictionary = p.expansion.records.get(key, {"score": 0, "time": 1e8})
			p.expansion.records[key] = {"score": maxi(previous.score, score), "time": minf(previous.time, elapsed)}
		p.metrics.wins += 1
		if stage.get("kind", "") != "challenge": MissionBoard.record(p, "wins")
		var story_key := "%d_after" % run.stage
		if story_key not in p.seen_story:
			p.seen_story.append(story_key)
		var rng := RandomNumberGenerator.new()
		rng.seed = int(run.seed)
		var loot: String = stage.drops[rng.randi_range(0, stage.drops.size() - 1)]
		if not _add_item(p, loot):
			if p.bag_rewards.size() >= 128: return false
			p.bag_rewards.append(loot)
	p.settled.append(run_id)
	if p.settled.size() > 64:
		p.settled.pop_front()
	p.pending = {}
	return commit(p)

func claim_quest(id: String) -> bool:
	var quest := catalog.find_row("quests", id)
	if quest.is_empty() or id in profile.claimed or profile.metrics[quest.metric] < quest.target:
		return false
	var p := profile.duplicate(true)
	p.gold += quest.gold
	p.shards += quest.shards
	p.claimed.append(id)
	return commit(p)

func offline_preview(now: int) -> int:
	var seconds := clampi(now - int(profile.last_offline), 0, 7200)
	return int(seconds / 60.0) * unlocked_stage() * 2

func claim_offline(now: int) -> bool:
	var amount := offline_preview(now)
	if amount <= 0:
		return false
	var p := profile.duplicate(true)
	p.gold += amount
	p.last_offline = maxi(now, int(p.last_offline))
	MissionBoard.record(p, "offline", 1, now)
	return commit(p)

func mark_story(key: String) -> bool:
	if key in profile.seen_story:
		return true
	var p := profile.duplicate(true)
	p.seen_story.append(key)
	return commit(p)

func setting(key: String, value: Variant) -> bool:
	if key not in ["speed", "sound"]:
		return false
	var p := profile.duplicate(true)
	p.settings[key] = value
	return commit(p)

func _decode(file_path: String) -> Variant:
	var raw = GameCatalog.normalize(JSON.parse_string(FileAccess.get_file_as_string(file_path)))
	var old_version: int = raw.get("version", 0) if raw is Dictionary else 0
	if raw is Dictionary and raw.get("version") == 2:
		raw.version = VERSION
		raw.expansion = Expansion.fresh(catalog)
		if raw.get("items") is Array:
			for item in raw.items:
				if item is Dictionary and item.get("base") is String and item.base not in raw.expansion.discovered:
					raw.expansion.discovered.append(item.base)
	elif raw is Dictionary and raw.get("version") in [3, 4]:
		raw.version = VERSION
		if raw.get("recruitment") is Dictionary and raw.recruitment.get("history") is Array:
			for entry in raw.recruitment.history:
				if not entry is Dictionary or entry.get("kind") not in ["hero", "spirit", "item"]: continue
				var id = entry.get("id")
				var group: String = {"hero": "heroes", "spirit": "assists", "item": "items"}[entry.kind]
				if catalog.find_row(group, id).is_empty(): continue
				var old_rarity: int = (1 if str(id).ends_with("_1") else (3 if id == "armor_4" else 2)) if entry.kind == "item" else (2 if id in ["eira", "lumi"] else 3)
				if entry.get("rarity") == old_rarity:
					entry["grade"] = old_rarity
					entry.rarity = Recruitment.rarity(entry.kind, id, catalog)
	if raw is Dictionary and old_version in [2, 3, 4, 5]:
		raw.version = VERSION
		if raw.get("heroes") is Dictionary and not raw.heroes.has("lyra"):
			raw.heroes["lyra"] = {"level": 1, "skills": [1, 1, 1], "equipment": {"weapon": "", "armor": ""}}
		if raw.get("expansion") is Dictionary and raw.expansion.get("builds") is Dictionary and not raw.expansion.builds.has("lyra"):
			raw.expansion.builds["lyra"] = {"learned": [], "selected": ["", "", ""]}
		for field in ["training", "evolution", "outfits"]:
			if raw.get(field) is Dictionary and not raw[field].has("lyra"):
				raw[field]["lyra"] = {"hp": 0, "atk": 0, "defense": 0} if field == "training" else ("original" if field == "outfits" else 1)
		if raw.get("recruitment") is Dictionary:
			for field in ["fragments", "awakening"]:
				if raw.recruitment.get(field) is Dictionary and not raw.recruitment[field].has("lyra"):
					raw.recruitment[field]["lyra"] = 0 if field == "fragments" else 1
	if old_version in [2, 3, 4, 5, 6]:
		raw.version = 6
		# Retired low gear grades become Rare; normalize only known legacy pairs.
		var old_item_rarities := {"sword_1": 1, "spear_1": 1, "staff_1": 1, "armor_1": 1, "armor_uncommon": 2}
		if raw.get("recruitment") is Dictionary and raw.recruitment.get("history") is Array:
			for entry in raw.recruitment.history:
				if entry is Dictionary and entry.get("kind") == "item" and old_item_rarities.has(entry.get("id")) and entry.get("rarity") == old_item_rarities[entry.id]:
					entry["legacy_rarity"] = entry.rarity
					entry.rarity = Recruitment.rarity("item", entry.id, catalog)
		if valid(raw, 6):
			raw.collection_fragments = CollectionFragments.fresh(catalog)
			EquipmentSystem.migrate(raw, catalog)
			raw.bag_rewards = []
			raw.version = VERSION
	if old_version in [7, 8] and valid(raw, old_version):
		EquipmentSystem.migrate(raw, catalog)
		raw.bag_rewards = []
		raw.version = VERSION
	if old_version == 9 and valid(raw, 9):
		EquipmentSystem.migrate(raw,catalog)
		raw.bag_rewards = []
		raw.version = VERSION
	if old_version == 10 and valid(raw,10):
		EquipmentSystem.migrate(raw,catalog)
		raw.version = VERSION
	return raw

func _whole(value: Variant, low: float, high: float) -> bool:
	return _number(value, low, high) and float(value) == floor(float(value))

func audio_settings(sound_enabled: bool, sfx: float, ambience: float, music: float = -1) -> bool:
	if not _number(sfx, 0, 1) or not _number(ambience, 0, 1) or (music != -1 and not _number(music,0,1)):
		return false
	var p := profile.duplicate(true)
	p.settings.sound = sound_enabled
	p.settings.sfx_volume = sfx
	p.settings.ambience_volume = ambience
	if music >= 0: p.settings.music_volume = music
	return commit(p)

func can_enter(id: int) -> bool:
	var stage := catalog.find_row("stages", id)
	if stage.is_empty(): return false
	if id <= 5: return id <= unlocked_stage()
	for required in stage.requires:
		if required not in profile.cleared: return false
	return true
