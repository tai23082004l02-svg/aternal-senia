class_name TacticalArenaBattle
extends ArenaBattle

# Snapshot v4 adds behavioral AI only; v3 keeps the original arena simulation.
func _spawn() -> void:
	super._spawn()
	for i in range(allies.size()):
		var ally: Dictionary = allies[i]
		ally.ai = run.team.units[i].ai.duplicate(true)
		ally.ai_target = -1
		ally.review_at = 0.0
		ally.pressure_until = 0.0
		ally.tactic_until = 0.0
		ally.tactic = "approach"
		ally.threats = {}
		ally.counter_pending = false
		ally.combo_pending = false
		ally.pursuit_pending = false
		ally.last_attacker = -1
		ally.attacked_at = -10.0

func _ally_target(ally: Dictionary) -> int:
	if focus >= 0 and focus < enemies.size() and enemies[focus].hp > 0: return focus
	var selected := _enemy_index(ally.ai_target)
	return selected if selected >= 0 else _nearest(ally.pos, enemies)

func _enemy_index(uid: int) -> int:
	for i in range(enemies.size()):
		if enemies[i].id == uid and enemies[i].hp > 0: return i
	return -1

func _roll(chance: float) -> bool:
	return chance > 0 and (chance >= 100 or rng.randf() * 100 < chance)

func _decide(ally: Dictionary) -> void:
	if time >= ally.review_at:
		ally.review_at = time + .6
		var target := _nearest(ally.pos, enemies)
		var attacker := _enemy_index(ally.last_attacker)
		if attacker >= 0 and time - ally.attacked_at < 1.5: target = attacker
		# Intercept threats near the weakest ally; this does not force enemy aggro.
		var weak := _lowest()
		if ally.stats.hero == "caelan" and weak >= 0 and allies[weak].hp < allies[weak].stats.hp * .65:
			var threat := _nearest(allies[weak].pos, enemies)
			if threat >= 0 and enemies[threat].pos.distance_to(allies[weak].pos) < 160: target = threat
		if target >= 0 and (_enemy_index(ally.ai_target) < 0 or _roll(ally.ai.switch)):
			ally.ai_target = enemies[target].id
	if ally.counter_pending:
		ally.counter_pending = false
		if _roll(ally.ai.counter):
			var attacker := _enemy_index(ally.last_attacker)
			if attacker >= 0: ally.ai_target = enemies[attacker].id
			ally.pressure_until = time + 1.0
			ally.clock = maxf(ally.clock, .55)
	if ally.combo_pending:
		ally.combo_pending = false
		if _roll(ally.ai.combo):
			ally.clock = maxf(ally.clock, .55)
			ally.pressure_until = time + .7
	if ally.pursuit_pending:
		ally.pursuit_pending = false
		if _roll(ally.ai.pursuit): ally.pressure_until = time + 1.2
	if time < ally.pressure_until:
		ally.tactic = "approach"
	elif time >= ally.tactic_until:
		ally.tactic_until = time + .8 + rng.randf() * .8
		if ally.hp < ally.stats.hp * .4:
			ally.tactic = "approach" if _roll(ally.ai.recklessness) else "retreat"
		else:
			ally.tactic = "approach" if _roll(ally.ai.aggression) else "orbit"

func _move_ally(ally: Dictionary) -> void:
	ally.moving = false
	ally.evading = false
	if ally.hp <= 0: return
	ally.evade_cd = maxf(0, ally.evade_cd - STEP)
	if not ally.action.is_empty(): return
	_decide(ally)
	if ally.ultimate_queued and ally.energy >= 100:
		ultimate(allies.find(ally))
		if not ally.action.is_empty(): return
	if time >= ally.evade_until and ally.evade_cd <= 0:
		for enemy in enemies:
			if enemy.hp <= 0 or enemy.action.is_empty() or enemy.action.hit: continue
			if time - enemy.action.started < .1 or ally.pos.distance_to(enemy.action.point) > enemy.action.radius + 8: continue
			if ally.threats.get(enemy.id, -1) == enemy.action.id: continue
			ally.threats[enemy.id] = enemy.action.id
			if not _roll(ally.ai.reaction): continue
			var away: Vector2 = ally.pos - enemy.action.point
			if away.length_squared() < 1: away = Vector2(-1, -1 if ally.pos.y > 211 else 1)
			var destination := _clamp(ally.pos + away.normalized() * 90)
			if destination.distance_to(enemy.action.point) <= enemy.action.radius + 12:
				destination = _clamp(ally.pos - away.normalized() * 100)
			ally.evade_direction = (destination - ally.pos).normalized()
			ally.evade_until = time + .42
			ally.evade_cd = ally.ai.evade_cooldown
			break
	if time < ally.evade_until:
		_move(ally, ally.evade_direction, ally.ai.speed * 1.65)
		ally.evading = true
		return
	var target := _ally_target(ally)
	if target < 0: return
	ally.target = target
	var delta: Vector2 = enemies[target].pos - ally.pos
	var distance := delta.length()
	var desired: float = ally.ai.range + (45.0 if ally.tactic == "retreat" else 0.0)
	var approach_distance := desired + 7 if ally.tactic == "retreat" else minf(desired + 7, _reach(ally) - 2)
	if distance > approach_distance:
		_move(ally, delta.normalized(), ally.ai.speed)
	elif distance < desired - (25 if _ranged(ally) else 8):
		_move(ally, -delta.normalized(), ally.ai.speed * .65)
	elif ally.tactic == "orbit":
		var side := 1.0 if ally.slot % 2 == 0 else -1.0
		_move(ally, delta.normalized().orthogonal() * side, ally.ai.speed * .25)
	if absf(delta.x) > 2: ally.face = signf(delta.x)

func _advance_ally(ally: Dictionary) -> void:
	var kind: String = ally.action.get("kind", "")
	super._advance_ally(ally)
	if ally.hp > 0 and ally.action.is_empty() and kind in ["attack", "basic"]:
		ally.combo_pending = true

func _damage_ally(index: int, amount: float, source: int) -> void:
	var before: float = allies[index].hp
	super._damage_ally(index, amount, source)
	if source < 0 or source >= enemies.size() or allies[index].hp <= 0: return
	allies[index].last_attacker = enemies[source].id
	allies[index].attacked_at = time
	if before == allies[index].hp: allies[index].counter_pending = true

func _resolve_enemy_action(enemy: Dictionary) -> void:
	super._resolve_enemy_action(enemy)
	if state != "battle": return
	for ally in allies:
		if ally.hp > 0 and ally.threats.get(enemy.id, -1) == enemy.action.id and ally.pos.distance_to(enemy.action.point) > enemy.action.radius:
			ally.last_attacker = enemy.id
			ally.attacked_at = time
			ally.counter_pending = true

func _damage_enemy(index: int, amount: float, ally: Dictionary, ability: bool, spirit: bool = false, dot: bool = false) -> void:
	var before: float = enemies[index].hp if index >= 0 and index < enemies.size() else 0.0
	super._damage_enemy(index, amount, ally, ability, spirit, dot)
	if not spirit and not dot and index >= 0 and index < enemies.size() and enemies[index].hp < before:
		ally.pursuit_pending = true

func _projectile_hit(shot: Dictionary, index: int) -> void:
	var before: float = enemies[index].hp
	super._projectile_hit(shot, index)
	if enemies[index].hp < before: allies[shot.source].pursuit_pending = true
