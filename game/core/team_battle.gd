class_name TeamBattle
extends BattleModel

var allies: Array = []
var enemies: Array = []
var encounter_data: Dictionary
var auto_ultimate := true
var auto_next := false
var spirit_energy := 0.0
var spirit_action: Dictionary = {}
var spirit_last := -100.0
var next_enemy_id := 0
var focus := -1
var defeat_reason := ""

func start(pending: Dictionary) -> void:
	run = pending.duplicate(true)
	stage = catalog.find_row("stages", run.stage).duplicate(true)
	encounter_data = run.team.encounter.duplicate(true)
	stats = run.team.units[0].stats.duplicate(true)
	auto_ultimate = run.team.auto_ult
	auto_next = run.team.auto_next
	rng.seed = int(run.seed)
	state = "battle"
	time = 0
	wave = 0
	kills = 0
	paused = false
	speed = 1
	accumulator = 0
	move_clock = 0
	assist_clock = 0
	spirit_energy = 0
	spirit_action = {}
	spirit_last = -100
	defeat_reason = ""
	events.clear()
	event_sequence = 0
	next_action = 1
	next_enemy_id = 0
	allies.clear()
	for row in run.team.units:
		var s: Dictionary = row.stats.duplicate(true)
		allies.append({"id":s.hero, "slot":int(row.slot), "stats":s, "hp":float(s.hp), "energy":0.0, "clock":float(row.slot) * .18, "basic_cd":0.0, "action":{}, "last":{}, "hurt":-100.0, "barrier":0.0, "barrier_until":0.0, "target":-1, "empowered":false})
	_spawn()

func wave_count() -> int:
	return encounter_data.waves.size()

func is_boss() -> bool:
	for enemy in enemies:
		if enemy.hp > 0 and enemy.boss: return true
	return false

func _spawn() -> void:
	enemies.clear()
	focus = -1
	var definition: Dictionary = encounter_data.waves[wave]
	spirit_action = {}
	for row in definition.units: _add_enemy(row)
	for ally in allies: ally.action = {}
	_team_emit("wave", -1, -1, "Đợt %d/%d" % [wave + 1, wave_count()], "boss_arrive" if is_boss() else "stage_start")
	_sync_totals()

func _add_enemy(row: Dictionary) -> void:
	if enemies.filter(func(e): return e.hp > 0).size() >= 4: return
	var enemy := row.duplicate(true)
	enemy.id = next_enemy_id
	next_enemy_id += 1
	enemy.max_hp = float(row.hp)
	enemy.hp = float(row.hp)
	enemy.clock = enemies.size() * -.23
	enemy.action = {}
	enemy.last = {}
	enemy.hurt = -100.0
	enemy.shield_broken = false
	enemy.summoned = false
	enemy.marked = false
	enemy.target = -1
	var reused := false
	for i in range(enemies.size()):
		if enemies[i].hp <= 0:
			enemies[i] = enemy
			reused = true
			break
	if not reused: enemies.append(enemy)

func _step() -> void:
	time += STEP
	if time >= encounter_data.limit:
		defeat_reason = "Hết thời gian"
		_end(false)
		return
	if move_clock > 0:
		move_clock = maxf(0, move_clock - STEP)
		if move_clock == 0: _spawn()
		return
	for ally in allies:
		if ally.hp <= 0: continue
		ally.energy = minf(100, ally.energy + STEP * 8)
		ally.basic_cd = maxf(0, ally.basic_cd - STEP)
		if time >= ally.barrier_until: ally.barrier = 0
		if not ally.action.is_empty():
			_advance_ally(ally)
		else:
			ally.clock += STEP
			if auto_ultimate and ally.energy >= 100: ultimate(allies.find(ally))
			elif ally.basic_cd <= 0 and ally.clock >= .95:
				_basic(ally)
			elif ally.clock >= .95: _schedule_ally(ally, "attack", 1.0, .22, .52)
		if state != "battle" or move_clock > 0: return
	assist_clock += STEP
	spirit_energy = minf(100, spirit_energy + STEP * 9)
	var companion: Dictionary = catalog.find_row("assists", stats.assist)
	if assist_clock >= companion.interval:
		assist_clock = 0
		_spirit(false)
	if auto_ultimate and spirit_energy >= 100: spirit_ultimate()
	if not spirit_action.is_empty():
		if not spirit_action.hit and time >= spirit_action.started + .5:
			spirit_action.hit = true
			_spirit(true)
		if not spirit_action.is_empty() and time >= spirit_action.started + .95: spirit_action = {}
	if state != "battle" or move_clock > 0: return
	for enemy in enemies.duplicate():
		if enemy.hp <= 0: continue
		var definition: Dictionary = encounter_data.waves[wave]
		if enemy.boss and not enemy.summoned and definition.summon_adds and enemy.hp <= enemy.max_hp * .5:
			enemy.summoned = true
			for i in range(2):
				_add_enemy({"type":"slime", "name":"Lính triệu hồi", "hp":definition.adds_hp, "atk":definition.adds_atk, "boss":false, "elite":false, "mechanic":"smash", "element":enemy.element})
			_team_emit("warning", -1, enemies.find(enemy), "Boss triệu hồi lính!", "cast")
		if enemy.action.is_empty():
			enemy.clock += STEP
			if enemy.clock >= (3.2 if enemy.boss else 2.8):
				enemy.clock = 0
				var target := _front()
				if target >= 0:
					enemy.target = target
					enemy.action = {"started":time, "marker":.6 if enemy.boss else .35, "duration":.9 if enemy.boss else .6, "target":target, "hit":false}
					enemy.last = enemy.action.duplicate(true)
					_team_emit("charge", enemies.find(enemy), target, "", "boss_charge" if enemy.boss else "enemy_charge", true)
		else:
			var action: Dictionary = enemy.action
			if not action.hit and time >= action.started + action.marker:
				action.hit = true
				var target: int = action.target if allies[action.target].hp > 0 else _front()
				if target >= 0: _damage_ally(target, enemy.atk * (1.5 if enemy.boss and enemy.mechanic == "smash" else 1.0), enemies.find(enemy))
			if time >= action.started + action.duration: enemy.action = {}
		if state != "battle": return
	_sync_totals()

func _front() -> int:
	var selected := -1
	var slot := 4
	for i in range(allies.size()):
		if allies[i].hp > 0 and allies[i].slot < slot:
			selected = i
			slot = allies[i].slot
	return selected

func _target() -> int:
	if focus >= 0 and focus < enemies.size() and enemies[focus].hp > 0: return focus
	for i in range(enemies.size()):
		if enemies[i].hp > 0: return i
	return -1

func select_target(index: int) -> bool:
	if paused or state != "battle" or index < 0 or index >= enemies.size() or enemies[index].hp <= 0: return false
	focus = index
	return true

func _lowest() -> int:
	var selected := -1
	var ratio := 2.0
	for i in range(allies.size()):
		var a: Dictionary = allies[i]
		if a.hp > 0 and a.hp / a.stats.hp < ratio:
			ratio = a.hp / a.stats.hp
			selected = i
	return selected

func _basic(ally: Dictionary) -> void:
	ally.basic_cd = 5.5 * ally.stats.get("cooldown_scale", 1.0)
	var heal: bool = ally.id == "mira" and _lowest() >= 0 and allies[_lowest()].hp < allies[_lowest()].stats.hp * .85
	var power: float = (1.7 + (ally.stats.skills[0] - 1) * .12) * ally.stats.skill_bonus
	if "focus" in ally.stats.get("variants", []): power *= 1.25
	_schedule_ally(ally, "heal" if heal else "basic", .15 + ally.stats.skills[1] * .025 if heal else power, .5, .95)

func _schedule_ally(ally: Dictionary, kind: String, power: float, marker: float, duration: float) -> void:
	ally.clock = 0
	ally.target = _lowest() if kind == "heal" else _target()
	ally.action = {"id":next_action, "kind":kind, "power":power, "marker":marker, "duration":duration, "started":time, "target":ally.target, "hit":false}
	next_action += 1
	ally.last = ally.action.duplicate(true)
	_team_emit("action", allies.find(ally), ally.target, "", "cast" if kind != "attack" else "swing_" + str(ally.stats.weapon).get_slice("_", 0))

func ultimate(index: int) -> bool:
	if paused or state != "battle" or move_clock > 0 or index < 0 or index >= allies.size(): return false
	var ally: Dictionary = allies[index]
	if ally.hp <= 0 or ally.energy < 100 or not ally.action.is_empty(): return false
	ally.energy = 0
	_schedule_ally(ally, "ultimate", 3.0 * ally.stats.skill_bonus * (1 + (ally.stats.skills[0] - 1) * .12), .5, .95)
	return true

func spirit_ultimate() -> bool:
	if paused or state != "battle" or move_clock > 0 or spirit_energy < 100 or not spirit_action.is_empty(): return false
	spirit_energy = 0
	spirit_action = {"started":time, "hit":false}
	_team_emit("action", -1, _target(), "", "burst")
	return true

func _advance_ally(ally: Dictionary) -> void:
	var action: Dictionary = ally.action
	if not action.hit and time >= action.started + action.marker:
		action.hit = true
		if action.kind == "heal":
			var target: int = action.target if action.target >= 0 and allies[action.target].hp > 0 else _lowest()
			if target >= 0:
				var power: float = action.power * (1.35 if "restoration" in ally.stats.get("variants", []) else 1.0)
				if ally.stats.get("weapon_trait", "") == "mending": power *= 1.15
				if "barrier" in ally.stats.get("variants", []):
					allies[target].barrier = maxf(allies[target].barrier, allies[target].stats.hp * .15)
					allies[target].barrier_until = time + 5
				_heal(target, allies[target].stats.hp * power, allies.find(ally))
		elif action.kind == "ultimate" and ally.id == "mira":
			for i in range(allies.size()):
				if allies[i].hp > 0:
					_heal(i, allies[i].stats.hp * (.22 + ally.stats.skills[1] * .02), allies.find(ally))
					allies[i].barrier = maxf(allies[i].barrier, allies[i].stats.hp * .12)
					allies[i].barrier_until = time + 5
		elif action.kind == "ultimate":
			for i in range(enemies.size()):
				if enemies[i].hp > 0: _damage_enemy(i, ally.stats.atk * action.power, ally, true)
			if ally.id == "ryn":
				ally.barrier = maxf(ally.barrier, ally.stats.hp * .18)
				ally.barrier_until = time + 5
		else:
			var target: int = action.target if action.target >= 0 and action.target < enemies.size() and enemies[action.target].hp > 0 else _target()
			if target >= 0: _damage_enemy(target, ally.stats.atk * action.power, ally, action.kind != "attack")
		ally.energy = minf(100, ally.energy + (8 if action.kind == "attack" else (12 if action.kind != "ultimate" else 0)))
	if time >= action.started + action.duration: ally.action = {}

func _damage_enemy(index: int, amount: float, ally: Dictionary, ability: bool, spirit: bool = false) -> void:
	if state != "battle" or move_clock > 0 or index >= enemies.size(): return
	var enemy: Dictionary = enemies[index]
	if enemy.hp <= 0: return
	var s: Dictionary = ally.stats
	var weapon_trait: String = s.get("weapon_trait", "")
	var critical: bool = not spirit and rng.randf() < s.crit
	if critical: amount *= 1.6
	var advantage := {"fire":"nature", "nature":"water", "water":"fire", "light":"dark", "dark":"light"}
	if advantage.get(s.element) == enemy.element: amount *= 1.2
	if weapon_trait == "execute" and enemy.hp < enemy.max_hp * .35: amount *= 1.2
	if enemy.marked:
		amount *= 1.2
		enemy.marked = false
	if ally.empowered:
		amount *= 1.3
		ally.empowered = false
	var shielded: bool = enemy.boss and enemy.mechanic == "shield" and not enemy.shield_broken
	if shielded:
		if spirit or ability and "breaker" in s.get("variants", []): enemy.shield_broken = true
		else: amount *= .7 if weapon_trait == "pierce" else .35
	amount = maxf(1, amount - int(stage.get("base_stage", run.stage)) * 1.5)
	enemy.hp = maxf(0, enemy.hp - amount)
	enemy.hurt = time
	var source := allies.find(ally)
	_team_emit("critical" if critical else "hit", source, index, str(int(amount)), "arrow_hit" if spirit else ("critical" if critical else "impact_" + str(s.weapon).get_slice("_", 0)))
	if weapon_trait == "spring" and not ability: ally.energy = minf(100, ally.energy + 2)
	if weapon_trait == "conduit" and ability: ally.energy = minf(100, ally.energy + 4)
	if enemy.hp <= 0:
		kills += 1
		enemy.action = {}
		_team_emit("down", source, index, "", "enemy_down")
	elif enemy.boss and enemy.mechanic == "counter" and ability and not spirit and not enemy.action.is_empty() and source >= 0:
		_damage_ally(source, enemy.atk * .65, index)
	if not enemies.any(func(e): return e.hp > 0):
		if wave + 1 == wave_count(): _end(true)
		else:
			wave += 1
			move_clock = .8
			spirit_action = {}
			for unit in allies: unit.action = {}
	_sync_totals()

func _damage_ally(index: int, amount: float, source: int) -> void:
	var ally: Dictionary = allies[index]
	if ally.hp <= 0: return
	amount = maxf(1, amount - ally.stats.defense)
	if ally.id == "ryn": amount *= .9
	var absorbed := minf(ally.barrier, amount)
	ally.barrier -= absorbed
	amount -= absorbed
	ally.hp = maxf(0, ally.hp - amount)
	ally.energy = minf(100, ally.energy + 10)
	ally.hurt = time
	if ally.stats.get("weapon_trait", "") == "riposte": ally.empowered = true
	_team_emit("hurt", source, index, str(int(amount)), "hurt", true)
	if ally.hp <= 0: ally.action = {}
	if _front() < 0:
		defeat_reason = "Toàn đội bị hạ"
		_end(false)
	_sync_totals()

func _heal(index: int, amount: float, source: int) -> void:
	var ally: Dictionary = allies[index]
	if ally.hp <= 0: return
	var actual := minf(amount, ally.stats.hp - ally.hp)
	ally.hp += actual
	_team_emit("heal", source, index, "+%d" % actual, "heal")

func _spirit(ultimate_cast: bool) -> void:
	spirit_last = time
	var rank: int = stats.get("assist_rank", 1)
	var scale: float = 1.0 + (stats.assist_level - 1) * .12
	if ultimate_cast:
		scale *= 1.0 + stats.skills[2] * .12
		if "nova" in stats.get("variants", []): scale *= 1.25
		if stats.get("spirit_advanced", "") == "echo": scale *= 1.15
	if stats.assist == "lumi":
		for i in range(allies.size()):
			if allies[i].hp <= 0: continue
			_heal(i, allies[i].stats.hp * (.22 if ultimate_cast else .07) * scale, -1)
			if rank >= 2 or ultimate_cast and stats.get("spirit_advanced", "") == "aegis":
				allies[i].barrier = maxf(allies[i].barrier, allies[i].stats.hp * .08)
				allies[i].barrier_until = time + 5
	else:
		var alive := allies.filter(func(a): return a.hp > 0)
		if alive.is_empty(): return
		var power := 0.0
		for ally in alive: power += ally.stats.atk
		power = power / alive.size() * (2.4 if ultimate_cast else .85) * scale
		for i in range(enemies.size()):
			if enemies[i].hp <= 0: continue
			_damage_enemy(i, power, alive[0], true, true)
			if rank >= 3 and i < enemies.size(): enemies[i].marked = true
			if state != "battle" or move_clock > 0: break
		_team_emit("assist", -1, _target(), "", "ash")
	if ultimate_cast and stats.get("spirit_advanced", "") == "aegis":
		for ally in allies:
			if ally.hp > 0:
				ally.barrier = maxf(ally.barrier, ally.stats.hp * .1)
				ally.barrier_until = time + 5

func _end(won: bool) -> void:
	state = "won" if won else "lost"
	for ally in allies: ally.action = {}
	for enemy in enemies: enemy.action = {}
	spirit_action = {}
	_team_emit("result", -1, -1, "CHIẾN THẮNG" if won else defeat_reason, "victory" if won else "defeat")
	_sync_totals()

func _sync_totals() -> void:
	hp = 0
	enemy_hp = 0
	enemy_max = 0
	for ally in allies: hp += ally.hp
	for enemy in enemies:
		enemy_hp += enemy.hp
		enemy_max += enemy.max_hp
	sp = spirit_energy

func _team_emit(kind: String, source: int, target: int, text: String, cue: String, enemy_source: bool = false) -> void:
	event_sequence += 1
	events.append({"id":event_sequence, "kind":kind, "source":source, "target":target, "enemy_source":enemy_source, "time":time, "text":text, "cue":cue, "action_id":next_action, "wave":wave, "target_uid":enemies[target].id if kind in ["hit","critical","down"] and target >= 0 and target < enemies.size() else -1, "visual":{}})
	if events.size() > 128: events.pop_front()

func warning() -> String:
	return "%s · %d/%d địch · %ds còn lại" % ["Boss" if is_boss() else "Chiến đấu", enemies.filter(func(e): return e.hp > 0).size(), enemies.size(), maxi(0, int(encounter_data.limit - time))]

# Retired singleton commands must never mutate the new unit model.
func attack() -> bool: return false
func guard() -> bool: return false
func skill(index: int) -> bool:
	return spirit_ultimate() if index == 2 else ultimate(index)
