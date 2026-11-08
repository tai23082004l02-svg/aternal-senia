class_name ArenaBattle
extends TeamBattle

# Snapshot v3: fixed-step arena rules. Old v1/v2 runs use TeamBattle unchanged.
# Coordinates are logical feet positions; rendering never advances this model.
const BOUNDS := Rect2(48, 120, 444, 182)
const HERO_SPEED := 112.0
const ENEMY_SPEED := 76.0
const MELEE_RANGE := 62.0
const RANGED_RANGE := 205.0
var projectiles: Array = []
var automatic_step := false

func start(pending: Dictionary) -> void:
	projectiles.clear()
	automatic_step = false
	super.start(pending)

func _spawn() -> void:
	projectiles.clear()
	super._spawn()
	for ally in allies:
		ally.pos = Vector2(180 if ally.slot < 2 else 85, 166 if ally.slot % 2 == 0 else 276)
		ally.face = 1.0
		ally.moving = false
		ally.evading = false
		ally.evade_until = 0.0
		ally.evade_cd = 0.0
		ally.evade_direction = Vector2.ZERO
		ally.ultimate_queued = false

func _add_enemy(row: Dictionary) -> void:
	var uid := next_enemy_id
	super._add_enemy(row)
	for i in range(enemies.size()):
		if enemies[i].id != uid: continue
		enemies[i].pos = Vector2(405 + (i % 2) * 45, 136 + i * 50)
		enemies[i].face = -1.0
		enemies[i].moving = false

func _ranged(ally: Dictionary) -> bool:
	return str(ally.stats.weapon).begins_with("staff")

func _reach(ally: Dictionary) -> float:
	return RANGED_RANGE if _ranged(ally) else MELEE_RANGE

func _nearest(point: Vector2, units: Array) -> int:
	var best := -1
	var distance := INF
	for i in range(units.size()):
		if units[i].hp <= 0: continue
		var d := point.distance_squared_to(units[i].pos)
		if d < distance:
			distance = d
			best = i
	return best

func _ally_target(ally: Dictionary) -> int:
	if focus >= 0 and focus < enemies.size() and enemies[focus].hp > 0: return focus
	return _nearest(ally.pos, enemies)

func _enemy_target(enemy: Dictionary) -> int:
	return _nearest(enemy.pos, allies)

func _enemy_in_range(enemy: Dictionary, index: int) -> bool:
	return enemy.pos.distance_to(allies[index].pos) <= (82.0 if enemy.boss else 58.0)

func _prepare_enemy_action(enemy: Dictionary) -> void:
	# Commit to a visible ground area. Moving away before the marker avoids it.
	enemy.action.point = allies[enemy.action.target].pos
	enemy.action.radius = 62.0 if enemy.boss else 38.0
	enemy.moving = false

func _resolve_enemy_action(enemy: Dictionary) -> void:
	var connected := false
	for i in range(allies.size()):
		if allies[i].hp <= 0: continue
		if allies[i].pos.distance_to(enemy.action.point) <= enemy.action.radius:
			_damage_ally(i, enemy.atk * (1.5 if enemy.boss and enemy.mechanic == "smash" else 1.0), enemies.find(enemy))
			connected = true
			if state != "battle": break
	if not connected: _team_emit("miss", enemies.find(enemy), -1, "Miss", "", true)

func _support(ally: Dictionary, kind: String) -> bool:
	if kind == "heal": return true
	if kind == "ultimate": return _hero_combat(ally).ultimate in ["team_heal", "team_barrier"]
	return kind == "basic" and prioritize_heal and _hero_combat(ally).basic == "adaptive_heal" and _lowest() >= 0 and allies[_lowest()].hp < allies[_lowest()].stats.hp * .85

func _schedule_ally(ally: Dictionary, kind: String, power: float, marker: float, duration: float) -> void:
	var target := _ally_target(ally)
	if not _support(ally, kind):
		if target < 0: return
		# Ultimate has its own larger range; it still requires an enemy in reach.
		var reach := _reach(ally) if kind != "ultimate" else 235.0
		if ally.pos.distance_to(enemies[target].pos) > reach: return
	super._schedule_ally(ally, kind, power, marker, duration)
	if kind == "ultimate" and _hero_combat(ally).ultimate == "execute" and ally.pos.distance_to(enemies[ally.target].pos) > 235.0:
		ally.target = target
		ally.action.target = target
	ally.moving = false
	ally.action.origin = ally.pos
	if ally.target >= 0 and kind != "heal" and not _support(ally, kind):
		ally.action.point = enemies[ally.target].pos
		ally.face = -1.0 if enemies[ally.target].pos.x < ally.pos.x else 1.0
	ally.last = ally.action.duplicate(true)

func _basic(ally: Dictionary) -> void:
	# Do not spend cooldowns while approaching an out-of-range target.
	var target := _ally_target(ally)
	if not _support(ally, "basic") and (target < 0 or ally.pos.distance_to(enemies[target].pos) > _reach(ally)): return
	super._basic(ally)

func ultimate(index: int) -> bool:
	if index < 0 or index >= allies.size(): return false
	var ally: Dictionary = allies[index]
	if paused or state != "battle" or move_clock > 0 or ally.hp <= 0 or ally.energy < 100 or not ally.action.is_empty(): return false
	if not _support(ally, "ultimate"):
		var target := _ally_target(ally)
		if target < 0: return false
		if ally.pos.distance_to(enemies[target].pos) > 235.0:
			if not automatic_step: ally.ultimate_queued = true
			return true
	ally.ultimate_queued = false
	return super.ultimate(index)

func _damage_enemy(index: int, amount: float, ally: Dictionary, ability: bool, spirit: bool = false, dot: bool = false) -> void:
	if not spirit and not dot:
		if index < 0 or index >= enemies.size() or enemies[index].hp <= 0: return
		var action: Dictionary = ally.action
		var kind: String = action.get("kind", "attack")
		var reach := 235.0 if kind == "ultimate" else _reach(ally) + 12.0
		var offset: Vector2 = enemies[index].pos - ally.pos
		var aim: Vector2 = action.get("point", enemies[index].pos) - action.get("origin", ally.pos)
		var facing_away := not _ranged(ally) and kind != "ultimate" and aim.length_squared() > .001 and aim.normalized().dot(offset.normalized()) < .2
		if offset.length() > reach or facing_away:
			_team_emit("miss", allies.find(ally), index, "Miss", "")
			return
		if _ranged(ally) and kind != "ultimate":
			# Aimed, non-homing magic bolt. Collision is resolved by simulation.
			var direction: Vector2 = (enemies[index].pos - ally.pos).normalized()
			projectiles.append({"pos":ally.pos, "velocity":direction * 330.0, "life":1.0, "source":allies.find(ally), "amount":amount, "ability":ability, "wave":wave})
			return
	super._damage_enemy(index, amount, ally, ability, spirit, dot)

func _step() -> void:
	if move_clock <= 0:
		_move_units()
		_step_projectiles()
		if state != "battle" or move_clock > 0: return
	automatic_step = true
	super._step()
	automatic_step = false

func _move_units() -> void:
	for ally in allies:
		ally.moving = false
		ally.evading = false
		if ally.hp <= 0: continue
		ally.evade_cd = maxf(0, ally.evade_cd - STEP)
		if not ally.action.is_empty(): continue
		if ally.ultimate_queued and ally.energy >= 100:
			ultimate(allies.find(ally))
			if not ally.action.is_empty(): continue
		if time >= ally.evade_until and ally.evade_cd <= 0:
			for enemy in enemies:
				if enemy.hp <= 0 or enemy.action.is_empty() or enemy.action.hit: continue
				if time - enemy.action.started < .1: continue
				if ally.pos.distance_to(enemy.action.point) > enemy.action.radius + 8: continue
				var away: Vector2 = ally.pos - enemy.action.point
				if away.length_squared() < 1: away = Vector2(-1, -1 if ally.pos.y > 211 else 1)
				var destination := _clamp(ally.pos + away.normalized() * 90)
				# Try the opposite escape when pinned at the arena boundary.
				if destination.distance_to(enemy.action.point) <= enemy.action.radius + 12:
					destination = _clamp(ally.pos - away.normalized() * 100)
				ally.evade_direction = (destination - ally.pos).normalized()
				ally.evade_until = time + .42
				ally.evade_cd = 3.5
				break
		if time < ally.evade_until:
			_move(ally, ally.evade_direction, HERO_SPEED * 1.65)
			ally.evading = true
			continue
		var target := _ally_target(ally)
		if target < 0: continue
		ally.target = target
		var delta: Vector2 = enemies[target].pos - ally.pos
		var distance := delta.length()
		var desired := 165.0 if _ranged(ally) else 49.0
		if distance > desired + 7:
			_move(ally, delta.normalized(), HERO_SPEED)
		elif _ranged(ally) and distance < desired - 25:
			_move(ally, -delta.normalized(), HERO_SPEED * .8)
		if absf(delta.x) > 2: ally.face = signf(delta.x)
	for enemy in enemies:
		enemy.moving = false
		if enemy.hp <= 0 or not enemy.action.is_empty(): continue
		var target := _enemy_target(enemy)
		if target < 0: continue
		enemy.target = target
		var delta: Vector2 = allies[target].pos - enemy.pos
		if delta.length() > (68.0 if enemy.boss else 47.0):
			_move(enemy, delta.normalized(), ENEMY_SPEED * (.8 if enemy.boss else 1.0))
		if absf(delta.x) > 2: enemy.face = signf(delta.x)
	# Resolve crowding in stable order without drawing or consuming random values.
	var units: Array = allies + enemies
	for i in range(units.size()):
		if units[i].hp <= 0: continue
		for j in range(i + 1, units.size()):
			if units[j].hp <= 0: continue
			var delta: Vector2 = units[j].pos - units[i].pos
			var distance := delta.length()
			if distance >= 44: continue
			var normal := delta / distance if distance > .001 else Vector2(0, 1)
			var push := normal * (44 - distance) * .5
			units[i].pos = _clamp(units[i].pos - push)
			units[j].pos = _clamp(units[j].pos + push)

func _clamp(point: Vector2) -> Vector2:
	return point.clamp(BOUNDS.position, BOUNDS.end)

func _move(unit: Dictionary, direction: Vector2, speed_value: float) -> void:
	var old: Vector2 = unit.pos
	unit.pos = _clamp(old + direction * speed_value * STEP)
	unit.moving = old.distance_squared_to(unit.pos) > .001

func _step_projectiles() -> void:
	for shot in projectiles.duplicate():
		if state != "battle" or move_clock > 0: break
		if shot.wave != wave: shot.life = 0; continue
		var old: Vector2 = shot.pos
		shot.pos += shot.velocity * STEP
		shot.life -= STEP
		var hit := -1
		var closest := INF
		for i in range(enemies.size()):
			if enemies[i].hp <= 0: continue
			var point := Geometry2D.get_closest_point_to_segment(enemies[i].pos, old, shot.pos)
			if point.distance_to(enemies[i].pos) <= 19 and old.distance_squared_to(point) < closest:
				hit = i
				closest = old.distance_squared_to(point)
		if hit >= 0:
			super._damage_enemy(hit, shot.amount, allies[shot.source], shot.ability)
			shot.life = 0
	projectiles = projectiles.filter(func(shot): return shot.life > 0 and shot.wave == wave and state == "battle" and move_clock <= 0)

func _end(won: bool) -> void:
	projectiles.clear()
	for unit in allies + enemies: unit.moving = false
	super._end(won)

func _team_emit(kind: String, source: int, target: int, text: String, cue: String, enemy_source: bool = false) -> void:
	super._team_emit(kind, source, target, text, cue, enemy_source)
	if target < 0: return
	var units: Array = allies if kind in ["hurt", "heal", "guard"] else enemies
	if target < units.size() and units[target].has("pos"):
		events[-1].arena_point = units[target].pos

func warning() -> String:
	return "AI Arena · " + super.warning()
