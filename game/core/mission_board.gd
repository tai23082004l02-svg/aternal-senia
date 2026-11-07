class_name MissionBoard
extends RefCounted

const TASKS := {
	"daily": [
		{"id":"offline", "name":"Nhận tiếp tế AFK", "target":1, "gold":30, "shards":0, "vip":5},
		{"id":"wins", "name":"Thắng 3 trận hành trình", "target":3, "gold":60, "shards":1, "vip":5},
		{"id":"kills", "name":"Hạ 12 kẻ địch", "target":12, "gold":40, "shards":1, "vip":5},
		{"id":"enhance", "name":"Cường hóa hoặc tiến bậc 1 lần", "target":1, "gold":30, "shards":1, "vip":5},
		{"id":"summon", "name":"Triệu hồi 1 lần", "target":1, "gold":40, "shards":1, "vip":5}],
	"weekly": [
		{"id":"offline", "name":"Nhận tiếp tế AFK 3 lần", "target":3, "gold":100, "shards":1, "vip":10},
		{"id":"wins", "name":"Thắng 10 trận hành trình", "target":10, "gold":180, "shards":3, "vip":10},
		{"id":"kills", "name":"Hạ 60 kẻ địch", "target":60, "gold":120, "shards":2, "vip":10},
		{"id":"enhance", "name":"Cường hóa hoặc tiến bậc 3 lần", "target":3, "gold":100, "shards":2, "vip":10},
		{"id":"summon", "name":"Triệu hồi 10 lần", "target":10, "gold":200, "shards":3, "vip":10}]
}
const CHESTS := [20, 40, 60, 80, 100]

static func now() -> int:
	return int(Time.get_unix_time_from_system())

static func key(period: String, timestamp: int) -> int:
	var day := int(timestamp / 86400.0)
	return day if period == "daily" else int((day + 3) / 7.0)

static func fresh_period(period: String, timestamp: int) -> Dictionary:
	return {"key":key(period, timestamp), "counts":{"offline":0,"wins":0,"kills":0,"enhance":0,"summon":0}, "claimed":[], "chests":[]}

static func state(p: Dictionary, timestamp: int = -1) -> Dictionary:
	if timestamp < 0: timestamp = now()
	var value: Dictionary = p.get("missions", {"vip_exp":0}).duplicate(true)
	for period in TASKS:
		if not value.has(period) or key(period, timestamp) > value[period].key:
			value[period] = fresh_period(period, timestamp)
	return value

static func valid(store, p: Dictionary) -> bool:
	if not p.has("missions"): return true
	var value = p.missions
	if not value is Dictionary or not store._whole(value.get("vip_exp"), 0, 1e12): return false
	for period in TASKS:
		var section = value.get(period)
		if not section is Dictionary or not store._whole(section.get("key"), 0, 1e12): return false
		if not section.get("counts") is Dictionary: return false
		if not section.get("claimed") is Array or not section.get("chests") is Array: return false
		if not Expansion.unique(section.claimed): return false
		var ids := []
		for task in TASKS[period]:
			ids.append(task.id)
			if not store._whole(section.counts.get(task.id), 0, task.target): return false
		for id in section.claimed:
			if id not in ids: return false
			for task in TASKS[period]:
				if task.id == id and section.counts[id] < task.target: return false
		var seen := {}
		for threshold in section.chests:
			if not store._whole(threshold, 20, 100) or int(threshold) not in CHESTS or seen.has(int(threshold)) or points(section, period) < threshold: return false
			seen[int(threshold)] = true
	return true

# Called on a transaction candidate, never commits or mutates the live profile.
static func record(p: Dictionary, event: String, amount: int = 1, timestamp: int = -1) -> void:
	p.missions = state(p, timestamp)
	for period in TASKS:
		for task in TASKS[period]:
			if task.id == event:
				p.missions[period].counts[event] = mini(task.target, p.missions[period].counts[event] + maxi(0, amount))

static func points(section: Dictionary, period: String) -> int:
	var total := 0
	for task in TASKS[period]:
		if section.counts[task.id] >= task.target: total += 20
	return total

static func chest_reward(period: String, threshold: int) -> Dictionary:
	var multiplier := 3 if period == "weekly" else 1
	return {"gold":threshold * multiplier, "shards":multiplier, "vip":10 * multiplier if threshold == 100 else 0}

static func claim(store, period: String, id: String = "", threshold: int = 0, timestamp: int = -1) -> bool:
	if period not in TASKS or store.read_only or not store.profile.pending.is_empty(): return false
	var p: Dictionary = store.profile.duplicate(true)
	p.missions = state(p, timestamp)
	var section: Dictionary = p.missions[period]
	var reward := {}
	if threshold > 0:
		if threshold not in CHESTS or threshold in section.chests or points(section, period) < threshold: return false
		reward = chest_reward(period, threshold)
		section.chests.append(threshold)
	else:
		if id in section.claimed: return false
		for task in TASKS[period]:
			if task.id == id and section.counts[id] >= task.target: reward = task
		if reward.is_empty(): return false
		section.claimed.append(id)
	p.gold += reward.gold
	p.shards += reward.shards
	p.missions.vip_exp += reward.vip
	return store.commit(p)

static func ready_count(p: Dictionary) -> int:
	var value := state(p)
	var total := 0
	for period in TASKS:
		var section: Dictionary = value[period]
		for task in TASKS[period]:
			if section.counts[task.id] >= task.target and task.id not in section.claimed: total += 1
		for threshold in CHESTS:
			if points(section, period) >= threshold and threshold not in section.chests: total += 1
	return total
