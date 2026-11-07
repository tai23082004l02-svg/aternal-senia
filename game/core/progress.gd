class_name ProgressStore
extends RefCounted

const VERSION = 3
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
		units[hero.id] = {"level": 1, "skills": [1, 1, 1], "equipment": {"weapon": "starter_" + hero.id, "armor": ""}}
	var bag: Array = []
	for hero in catalog.data.heroes:
		bag.append({"uid": "starter_" + hero.id, "base": catalog.category(hero.id) + "_1", "enhance": 0, "rank": 1})
	return {"expansion": Expansion.fresh(catalog), "version": VERSION, "gold": 0, "shards": 0, "xp": 0, "hero": "eira", "assist": "lumi", "heroes": units, "assists": {"lumi": 1, "ash": 1}, "items": bag, "next_uid": 1, "cleared": [], "claimed": [], "metrics": {"wins": 0, "kills": 0, "enhances": 0, "clears": 0}, "seen_story": [], "last_offline": int(Time.get_unix_time_from_system()), "pending": {}, "settled": [], "settings": {"speed": 1, "sound": true}}

func valid(p: Variant) -> bool:
	if not p is Dictionary or p.get("version") != VERSION:
		return false
	for key in fresh():
		if not p.has(key):
			return false
	for key in ["gold", "shards", "xp", "next_uid", "last_offline"]:
		if not _whole(p[key], 0, 1e12):
			return false
	if not p.hero is String or catalog.find_row("heroes", p.hero).is_empty() or catalog.find_row("assists", p.assist).is_empty():
		return false
	if not p.heroes is Dictionary or not p.assists is Dictionary or not p.items is Array or p.items.size() > BAG_CAP:
		return false
	var uids: Array = []
	for item in p.items:
		if not item is Dictionary or not item.get("uid") is String or item.uid.is_empty() or item.uid in uids:
			return false
		if catalog.find_row("items", item.get("base")).is_empty() or not _whole(item.get("enhance"), 0, 10) or not _whole(item.get("rank"), 1, 3):
			return false
		uids.append(item.uid)
	var equipped: Array = []
	for hero in catalog.data.heroes:
		var unit = p.heroes.get(hero.id)
		if not unit is Dictionary or not _whole(unit.get("level"), 1, 100) or not unit.get("skills") is Array or unit.skills.size() != 3 or not unit.get("equipment") is Dictionary:
			return false
		for lv in unit.skills:
			if not _whole(lv, 1, 10):
				return false
		for slot in ["weapon", "armor"]:
			var uid = unit.equipment.get(slot)
			if not uid is String:
				return false
			if uid.is_empty():
				continue
			if uid not in uids or uid in equipped:
				return false
			equipped.append(uid)
			var item: Dictionary = p.items[uids.find(uid)]
			var def := catalog.find_row("items", item.base)
			if def.slot != slot or (slot == "weapon" and def.category != catalog.category(hero.id)):
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
	for key in ["sfx_volume", "ambience_volume"]:
		if p.settings.has(key) and not _number(p.settings[key], 0, 1):
			return false
	if not Expansion.valid(self, p.get("expansion")): return false
	if not AttributeTraining.valid(self, p): return false
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
	return catalog.find_row("heroes", id).unlock <= unlocked_stage()

func change_hero(id: String) -> bool:
	if not available_hero(id) or not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	p.hero = id
	return commit(p)

func change_assist(id: String) -> bool:
	if catalog.find_row("assists", id).unlock > unlocked_stage() or not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	p.assist = id
	return commit(p)

func upgrade(kind: String, index: int = 0) -> bool:
	if not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	var unit: Dictionary = p.heroes[p.hero]
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

func equip(uid: String) -> bool:
	if not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	for item in p.items:
		if item.uid != uid:
			continue
		var def := catalog.find_row("items", item.base)
		if def.slot == "weapon" and def.category != catalog.category(p.hero):
			return false
		for hero in p.heroes:
			if uid in p.heroes[hero].equipment.values():
				return false
		p.heroes[p.hero].equipment[def.slot] = uid
		return commit(p)
	return false

func unequip(uid: String) -> bool:
	if not profile.pending.is_empty():
		return false
	var p := profile.duplicate(true)
	for slot in ["weapon", "armor"]:
		if p.heroes[p.hero].equipment[slot] == uid:
			p.heroes[p.hero].equipment[slot] = ""
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
		if p.gold < cost or p.shards < shards or (rank_up and item.rank >= 3) or (not rank_up and item.enhance >= 10):
			return false
		p.gold -= cost
		p.shards -= shards
		if rank_up:
			item.rank += 1
		else:
			item.enhance += 1
		p.metrics.enhances += 1
		return commit(p)
	return false

func forge(base: String) -> bool:
	if not profile.pending.is_empty() or catalog.find_row("items", base).is_empty() or profile.items.size() >= BAG_CAP or profile.gold < 65 or profile.shards < 3:
		return false
	var p := profile.duplicate(true)
	p.gold -= 65
	p.shards -= 3
	_add_item(p, base)
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

func _add_item(p: Dictionary, base: String) -> void:
	if p.items.size() >= BAG_CAP:
		p.shards += 3
		return
	if base not in p.expansion.discovered: p.expansion.discovered.append(base)
	p.items.append({"uid": "item_%d" % int(p.next_uid), "base": base, "enhance": 0, "rank": 1})
	p.next_uid += 1

func begin_run(stage_id: int) -> bool:
	if not profile.pending.is_empty() or not can_enter(stage_id):
		return false
	var p := profile.duplicate(true)
	p.pending = {"id": "%d_%d" % [Time.get_unix_time_from_system(), Time.get_ticks_usec()], "stage": stage_id, "seed": randi_range(1, 2147483646), "stats": catalog.stats(p)}
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
	p.metrics.kills += clampi(kills, 0, stage.get("waves", [0, 0, 0]).size())
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
		var story_key := "%d_after" % run.stage
		if story_key not in p.seen_story:
			p.seen_story.append(story_key)
		var rng := RandomNumberGenerator.new()
		rng.seed = int(run.seed)
		_add_item(p, stage.drops[rng.randi_range(0, stage.drops.size() - 1)])
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
	if raw is Dictionary and raw.get("version") == 2:
		raw.version = VERSION
		raw.expansion = Expansion.fresh(catalog)
		if raw.get("items") is Array:
			for item in raw.items:
				if item is Dictionary and item.get("base") is String and item.base not in raw.expansion.discovered:
					raw.expansion.discovered.append(item.base)
	return raw

func _whole(value: Variant, low: float, high: float) -> bool:
	return _number(value, low, high) and float(value) == floor(float(value))

func audio_settings(sound_enabled: bool, sfx: float, ambience: float) -> bool:
	if not _number(sfx, 0, 1) or not _number(ambience, 0, 1):
		return false
	var p := profile.duplicate(true)
	p.settings.sound = sound_enabled
	p.settings.sfx_volume = sfx
	p.settings.ambience_volume = ambience
	return commit(p)

func can_enter(id: int) -> bool:
	var stage := catalog.find_row("stages", id)
	if stage.is_empty(): return false
	if id <= 5: return id <= unlocked_stage()
	for required in stage.requires:
		if required not in profile.cleared: return false
	return true
