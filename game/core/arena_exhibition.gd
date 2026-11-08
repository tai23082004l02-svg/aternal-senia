class_name ArenaExhibition
extends TacticalArenaBattle

# RAM-only hero-versus-hero presentation match. Never enters ProgressStore.
var teams: Array = [[], []]
var active_side := 0
var winner := -1

func start_match(profile: Dictionary, selection: Array, match_seed: int, durability: int = 3, full_energy: bool = true) -> bool:
	if selection.size() != 2 or durability not in [1,3,5]: return false
	for roster in selection:
		if not roster is Array or roster.is_empty() or roster.size() > 4: return false
		var seen := []
		for id in roster:
			if not id is String or id in seen or catalog.find_row("heroes",id).is_empty(): return false
			seen.append(id)
	teams = [[], []]
	for side in range(2):
		var copy := profile.duplicate(true)
		copy.hero = selection[side][0]
		copy.formation = {"slots":selection[side].duplicate(),"auto_ult":true,"auto_next":false}
		var snapshot := Formation.snapshot(catalog,copy,catalog.find_row("stages",1))
		var temporary := TacticalArenaBattle.new(catalog)
		temporary.start({"id":"exhibition-build","stage":1,"seed":match_seed,"team":snapshot})
		teams[side] = temporary.allies.duplicate(true)
		for i in range(teams[side].size()):
			var unit: Dictionary = teams[side][i]
			unit.id = side * 4 + i
			unit.stats.hp *= durability
			unit.hp = unit.stats.hp
			unit.max_hp = unit.hp
			unit.element = unit.stats.element
			unit.energy = 100.0 if full_energy else 0.0
			unit.pos = Vector2(110 + (35 if i < 2 else -25),145 + (i % 2)*130 + (18 if i >= 2 else 0))
			if side == 1: unit.pos.x = 540 - unit.pos.x
			unit.face = 1.0 if side == 0 else -1.0
	run = {"id":"exhibition-%d" % Time.get_ticks_usec()}
	rng.seed = match_seed
	time = 0
	accumulator = 0
	move_clock = 0
	wave = 0
	state = "battle"
	paused = false
	speed = 1
	winner = -1
	auto_ultimate = true
	prioritize_heal = true
	projectiles.clear()
	events.clear()
	event_sequence = 0
	next_action = 1
	_use_side(0)
	_sync_totals()
	return true

func _use_side(side: int) -> void:
	active_side = side
	allies = teams[side]
	enemies = teams[1-side]
	stats = allies[0].stats
	focus = -1

func _step() -> void:
	time += STEP
	if time >= 180:
		_end(false)
		return
	for side in range(2):
		_use_side(side)
		for unit in allies: _move_ally(unit)
	# Stable crowd separation across both teams.
	var units: Array = teams[0] + teams[1]
	for i in range(units.size()):
		if units[i].hp <= 0: continue
		for j in range(i+1,units.size()):
			if units[j].hp <= 0: continue
			var delta: Vector2 = units[j].pos - units[i].pos
			var distance := delta.length()
			if distance >= 44: continue
			var normal := delta/distance if distance > .001 else Vector2(0,1)
			units[i].pos = _clamp(units[i].pos-normal*(44-distance)*.5)
			units[j].pos = _clamp(units[j].pos+normal*(44-distance)*.5)
	_step_projectiles()
	if state != "battle": return
	for side in range(2):
		_use_side(side)
		for unit in allies:
			if unit.hp <= 0: continue
			unit.energy = minf(100,unit.energy+STEP*(8+unit.stats.get("sp_regen",0)))
			unit.basic_cd = maxf(0,unit.basic_cd-STEP)
			if time >= unit.barrier_until: unit.barrier = 0
			if not unit.action.is_empty(): _advance_ally(unit)
			else:
				unit.clock += STEP*(1+unit.stats.get("haste",0))
				if auto_ultimate and unit.energy >= 100: ultimate(allies.find(unit))
				elif unit.basic_cd <= 0 and unit.clock >= .95: _basic(unit)
				elif unit.clock >= .95: _schedule_ally(unit,"attack",1,.22,.52)
			if state != "battle": return
	_use_side(0)
	_sync_totals()

func _damage_enemy(index: int, amount: float, ally: Dictionary, ability: bool, _spirit: bool = false, _dot: bool = false) -> void:
	if state != "battle" or index < 0 or index >= enemies.size() or enemies[index].hp <= 0: return
	var action: Dictionary = ally.action
	var kind: String = action.get("kind","attack")
	var offset: Vector2 = enemies[index].pos-ally.pos
	var aim: Vector2 = action.get("point",enemies[index].pos)-action.get("origin",ally.pos)
	if offset.length() > (235.0 if kind == "ultimate" else _reach(ally)+12): return
	if not _ranged(ally) and kind != "ultimate" and aim.length_squared() > .001 and aim.normalized().dot(offset.normalized()) < .2: return
	if _ranged(ally) and kind != "ultimate":
		projectiles.append({"side":active_side,"source":allies.find(ally),"pos":ally.pos,"velocity":offset.normalized()*330,"life":1.0,"amount":amount,"ability":ability})
	else: _strike(index,amount,allies.find(ally),ability)

func _schedule_ally(ally: Dictionary, kind: String, power: float, marker: float, duration: float) -> void:
	super._schedule_ally(ally,kind,power,marker,duration)
	if ally.action.is_empty(): return
	ally.action.radius = 62.0 if kind == "ultimate" else 38.0
	if not ally.action.has("point"): ally.action.point = Vector2(-1000,-1000)
	ally.last = ally.action.duplicate(true)

func _strike(index: int, amount: float, source: int, ability: bool) -> void:
	var side := active_side
	var caster: Dictionary = allies[source]
	var target: Dictionary = enemies[index]
	if target.hp <= 0: return
	var kit := _hero_combat(caster)
	if kit.has("execute_threshold") and target.hp/target.max_hp < kit.execute_threshold: amount *= kit.execute_multiplier
	if rng.randf() < caster.stats.crit: amount *= 1.6
	var advantage := {"fire":"nature","nature":"water","water":"fire","light":"dark","dark":"light"}
	if advantage.get(caster.stats.element) == target.stats.element: amount *= 1.2
	if caster.empowered:
		amount *= 1.3
		caster.empowered = false
	var before: float = target.hp
	_use_side(1-side)
	# Existing hero defenses, shields, evasion, guard aura and death rules.
	super._damage_ally(index,amount,source)
	_use_side(side)
	if target.hp < before: caster.pursuit_pending = true
	if caster.stats.get("weapon_trait","") == "spring" and not ability: caster.energy = minf(100,caster.energy+2)
	if caster.stats.get("weapon_trait","") == "conduit" and ability: caster.energy = minf(100,caster.energy+4)

func _step_projectiles() -> void:
	for shot in projectiles.duplicate():
		if state != "battle": break
		_use_side(shot.side)
		var old: Vector2 = shot.pos
		shot.pos += shot.velocity*STEP
		shot.life -= STEP
		var closest := INF
		var hit := -1
		for i in range(enemies.size()):
			if enemies[i].hp <= 0: continue
			var point := Geometry2D.get_closest_point_to_segment(enemies[i].pos,old,shot.pos)
			if point.distance_to(enemies[i].pos) < 19 and old.distance_squared_to(point) < closest:
				closest = old.distance_squared_to(point)
				hit = i
		if hit >= 0:
			_strike(hit,shot.amount,shot.source,shot.ability)
			shot.life = 0
	projectiles = projectiles.filter(func(s): return s.life > 0 and state == "battle")

func _end(_won: bool) -> void:
	var alive_a: bool = teams[0].any(func(u): return u.hp > 0)
	var alive_b: bool = teams[1].any(func(u): return u.hp > 0)
	winner = 0 if alive_a and not alive_b else (1 if alive_b and not alive_a else -1)
	state = "won"
	for unit in teams[0]+teams[1]:
		unit.action = {}
		unit.moving = false
	projectiles.clear()
	_team_emit("result",-1,-1,"Draw" if winner < 0 else "Team %s wins" % ["A","B"][winner],"victory")
	_sync_totals()

func _sync_totals() -> void:
	hp = 0
	enemy_hp = 0
	for unit in teams[0]: hp += unit.hp
	for unit in teams[1]: enemy_hp += unit.hp

func _team_emit(kind: String, source: int, target: int, text: String, cue: String, enemy_source: bool = false) -> void:
	var target_side := active_side if kind in ["hurt","heal","guard"] else 1-active_side
	var point := Vector2.ZERO
	if target >= 0 and target < teams[target_side].size(): point = teams[target_side][target].pos
	event_sequence += 1
	events.append({"id":event_sequence,"kind":kind,"source":source,"target":target,"side":target_side,"time":time,"text":text,"cue":cue,"point":point,"enemy_source":enemy_source})
	if events.size() > 128: events.pop_front()
