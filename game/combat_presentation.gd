class_name CombatPresentation
extends RefCounted

# Read-only pose sampling. It never ticks BattleModel or plays sound.
static func hero(battle: BattleModel, world_time: float) -> Dictionary:
	var result := {"state": "idle", "time": world_time, "offset": Vector2.ZERO, "marker": -1.0, "duration": -1.0}
	if battle.state == "lost":
		result.state = "death"
		result.time = maxf(0, world_time - battle.time)
		return result
	var action: Dictionary = battle.last_action
	if not action.is_empty():
		var age: float = world_time - action.started
		if age >= 0 and age < action.duration:
			result.state = "skill" if action.skill else "attack"
			result.time = age
			result.marker = action.marker
			result.duration = action.duration
			if action.kind == "damage":
				result.offset.x = lunge(age, action.marker, action.duration, action.burst)
	if battle.move_clock > 0:
		var progress := clampf((.8 - battle.move_clock) / .8, 0, 1)
		result.offset.x += sin(progress * PI) * 24
		if result.state == "idle":
			result.state = "run"
			result.time = .8 - battle.move_clock
	if battle.guard_left > 0 and result.state == "idle":
		result.state = "guard"
		result.time = .7 - battle.guard_left
	if battle.hurt_left > 0:
		result.state = "hurt"
		result.time = .25 - battle.hurt_left
		result.offset.x -= sin(result.time / .25 * PI) * 7
	return result

static func lunge(age: float, marker: float, duration: float, burst: bool = false) -> float:
	var peak := 64.0 if not burst else 49.0
	var prep := marker * .48
	if age < prep:
		return -7 * sin(clampf(age / prep, 0, 1) * PI * .5)
	if age < marker:
		return lerpf(-7, peak, smoothstep(prep, marker, age))
	var hold := minf(duration - .05, marker + .045)
	if age < hold:
		return peak
	return lerpf(peak, 0, smoothstep(hold, duration, age))

static func target(wave: int) -> Vector2:
	return [Vector2(362, 443), Vector2(356, 420), Vector2(354, 385)][clampi(wave, 0, 2)]

static func guardian(battle: BattleModel, world_time: float) -> Dictionary:
	var elapsed := world_time - battle.last_enemy_strike
	if elapsed >= 0 and elapsed < .52:
		return {"state": "slam", "time": elapsed}
	if battle.enemy_clock >= 2 and battle.state == "battle" and battle.move_clock <= 0:
		return {"state": "charge", "time": battle.enemy_clock - 2}
	return {"state": "idle", "time": world_time}
