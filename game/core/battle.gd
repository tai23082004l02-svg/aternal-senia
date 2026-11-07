class_name BattleModel
extends RefCounted

const STEP := 1.0 / 60.0
var catalog: GameCatalog
var run: Dictionary
var stats: Dictionary
var stage: Dictionary
var rng := RandomNumberGenerator.new()
var state := "idle"
var hp := 1.0
var enemy_hp := 1.0
var enemy_max := 1.0
var sp := 100.0
var wave := 0
var kills := 0
var time := 0.0
var enemy_clock := 0.0
var attack_clock := 0.0
var assist_clock := 0.0
var move_clock := 0.0
var guard_left := 0.0
var guard_cd := 0.0
var cooldowns: Array = [0.0, 0.0, 0.0]
var actions: Array = []
var events: Array = []
var next_action := 1
var event_sequence := 0
var combo := 0
var shield := false
var shield_broken := false
var paused := false
var auto_attack := true
var speed := 1
var accumulator := 0.0
var last_action: Dictionary = {}
var last_enemy_strike := -1000.0
var hero_pose := "idle"
var hero_pose_time := 0.0
var hurt_left := 0.0
var enemy_hurt := 0.0
var assist_flash := 0.0
var notice := ""
var barrier := 0.0
var barrier_left := 0.0
var empowered := 0.0
var marked := false

func _init(book: GameCatalog) -> void:
	catalog = book

func start(pending: Dictionary) -> void:
	run = pending.duplicate(true)
	stats = run.stats.duplicate(true)
	stage = catalog.find_row("stages", run.stage).duplicate(true)
	barrier = 0
	barrier_left = 0
	empowered = 0
	marked = false
	rng.seed = int(run.seed)
	hp = stats.hp
	sp = 100.0
	wave = 0
	kills = 0
	time = 0
	cooldowns = [0.0, 0.0, 0.0]
	actions.clear()
	last_action = {}
	last_enemy_strike = -1000.0
	events.clear()
	state = "battle"
	_spawn()

func wave_count() -> int:
	return stage.get("waves", [0, 0, 0]).size()

func is_boss() -> bool:
	return bool(stage.waves[wave].boss) if stage.has("waves") else wave == 2

func variant(id: String) -> bool:
	return id in stats.get("variants", [])

func has_trait(id: String) -> bool:
	return stats.get("weapon_trait", "") == id

func _barrier(amount: float) -> void:
	barrier = maxf(barrier, amount)
	barrier_left = 5
	_emit("guard", "Khiên bảo hộ", 0, "guard_ready")

func _spawn() -> void:
	marked = false
	if stage.has("waves"):
		stage.mechanic = stage.waves[wave].mechanic
		for key in ["name", "zone", "element"]:
			if stage.waves[wave].has(key): stage["boss" if key == "name" else key] = stage.waves[wave][key]
	enemy_max = float(stage.boss_hp) if is_boss() else float(stage.enemy_hp) * (1.0 + wave * 0.35)
	if stage.has("waves"): enemy_max = float(stage.waves[wave].hp)
	enemy_hp = enemy_max
	enemy_clock = 0.0
	attack_clock = 0.0
	shield_broken = false
	shield = false
	hero_pose = "idle"
	hero_pose_time = 0
	_emit("wave", "BOSS · " + stage.boss if is_boss() else "Đợt %d / %d" % [wave + 1, wave_count()], 0, "boss_arrive" if is_boss() else "stage_start")

func advance(delta: float) -> void:
	if paused or state != "battle":
		return
	accumulator += minf(delta, 0.25) * speed
	while accumulator >= STEP and state == "battle":
		accumulator -= STEP
		_step()

func _step() -> void:
	time += STEP
	barrier_left = maxf(0, barrier_left - STEP)
	if barrier_left <= 0: barrier = 0
	empowered = maxf(0, empowered - STEP)
	hero_pose_time += STEP
	hurt_left = maxf(0, hurt_left - STEP)
	enemy_hurt = maxf(0, enemy_hurt - STEP)
	assist_flash = maxf(0, assist_flash - STEP)
	guard_left = maxf(0, guard_left - STEP)
	guard_cd = maxf(0, guard_cd - STEP)
	for i in range(3):
		cooldowns[i] = maxf(0, float(cooldowns[i]) - STEP)
	sp = minf(100, sp + STEP * 6)
	if move_clock > 0:
		var before_move := move_clock
		move_clock -= STEP
		for marker in [.6, .2]:
			if before_move > marker and move_clock <= marker:
				_sound("step")
		hero_pose = "run"
		if move_clock <= 0:
			_spawn()
		return
	if hero_pose_time > 0.7 and actions.is_empty():
		hero_pose = "idle"
	attack_clock += STEP
	assist_clock += STEP
	enemy_clock += STEP
	if enemy_clock >= 2.0 and enemy_clock - STEP < 2.0:
		_sound("boss_charge" if is_boss() else "enemy_charge")
	var previous_shield := shield
	shield = is_boss() and stage.mechanic == "shield" and not shield_broken and fmod(enemy_clock, 5.0) < 2.8
	if shield and not previous_shield:
		_sound("shield_on")
	if auto_attack and attack_clock >= 0.85 and actions.is_empty():
		attack()
	var companion := catalog.find_row("assists", stats.assist)
	if assist_clock >= companion.interval:
		assist_clock = 0
		assist_flash = .5
		if stats.assist == "lumi":
			var heal: float = stats.hp * companion.power * (1 + (stats.assist_level - 1) * .12)
			if stats.get("assist_rank", 1) >= 3: heal *= 1.25
			hp = minf(stats.hp, hp + heal)
			if stats.get("assist_rank", 1) >= 2: _barrier(stats.hp * .08)
			_emit("heal", "+%d" % heal, 0, "lumi")
		else:
			_sound("ash")
			_hit(stats.atk * companion.power * (1 + (stats.assist_level - 1) * .15), false, "assist")
			if stats.get("assist_rank", 1) >= 3: marked = true
	if state != "battle" or move_clock > 0:
		return
	# Iterate all crossed markers; damage belongs to simulation, never the view.
	for action in actions.duplicate():
		action.elapsed += STEP
		if not action.sound_fired and action.elapsed >= action.sound_marker:
			action.sound_fired = true
			if action.wave == wave:
				_sound(action.sound_cue, action.id)
		if not action.hit and action.elapsed >= action.marker:
			action.hit = true
			if action.wave == wave:
				if action.skill and has_trait("conduit"): sp = minf(100, sp + 4)
				if action.kind == "heal":
					var healed: float = stats.hp * action.power * (1.25 if stats.hero == "mira" else 1.0)
					if has_trait("mending"): healed *= 1.15
					if variant("barrier"): _barrier(stats.hp * .15)
					hp = minf(stats.hp, hp + healed)
					_emit("heal", "+%d" % healed, 0, "heal", action.id)
				else:
					if action.burst and stats.get("spirit_advanced", "") == "aegis": _barrier(stats.hp * .1)
					if action.burst or (action.skill and action.get("breaker", false)):
						if shield:
							_sound("shield_break", action.id)
						shield_broken = true
						shield = false
					var counter: bool = is_boss() and stage.mechanic == "counter" and enemy_clock >= 2.0 and action.skill
					_hit(stats.atk * action.power * (1.15 if action.burst and stats.get("spirit_advanced", "") == "echo" else 1.0), true, "weapon", action.id)
					if counter and state == "battle" and move_clock <= 0:
						_take_damage(stage.boss_atk * .65)
						_emit("warning", "Phản đòn!", 1, "counter", action.id)
		if action.elapsed >= action.duration:
			actions.erase(action)
		if state != "battle" or move_clock > 0:
			break
	if state == "battle" and move_clock <= 0 and enemy_clock >= 3.0:
		enemy_clock = 0
		var damage := float(stage.boss_atk) if is_boss() else float(stage.enemy_atk)
		if stage.has("waves"): damage = float(stage.waves[wave].atk)
		if is_boss() and stage.mechanic == "smash":
			damage *= 1.5
		if is_boss():
			_sound("boss_slam")
		_take_damage(damage)

func attack() -> bool:
	if state != "battle" or paused or move_clock > 0 or attack_clock < .38 or not actions.is_empty():
		return false
	attack_clock = 0
	combo = combo % 3 + 1
	_schedule("damage", 1.0 + (combo - 1) * .12, .22, .52, false, false)
	sp = minf(100, sp + 4)
	return true

func skill(index: int) -> bool:
	if state != "battle" or paused or move_clock > 0 or index < 0 or index > 2 or cooldowns[index] > 0 or not actions.is_empty():
		return false
	var def: Dictionary = catalog.data.skills[index]
	var cost: float = 25 if index == 2 and variant("flow") else def.cost
	if sp < cost:
		return false
	sp -= cost
	cooldowns[index] = def.cd * stats.get("cooldown_scale", 1.0) * (.8 if index == 2 and variant("flow") else 1.0)
	var power: float = def.power * (1 + (stats.skills[index] - 1) * .12)
	if def.kind == "damage":
		power *= stats.skill_bonus
	if (index == 0 and variant("focus")) or (index == 2 and variant("nova")): power *= 1.25
	if index == 1 and variant("restoration"): power *= 1.35
	_schedule(def.kind, power, def.hit, def.duration, true, index == 2)
	actions.back().breaker = index == 0 and variant("breaker")
	return true

func _schedule(kind: String, power: float, marker: float, duration: float, is_skill: bool, burst: bool) -> void:
	actions.append({"id": next_action, "elapsed": 0.0, "hit": false, "wave": wave, "marker": marker, "duration": duration, "kind": kind, "power": power, "skill": is_skill, "burst": burst, "started": time, "combo": combo, "sound_fired": kind == "heal", "sound_marker": maxf(0, marker - .09), "sound_cue": "burst" if burst else "swing_" + str(stats.weapon).get_slice("_", 0)})
	last_action = actions.back().duplicate(true)
	_emit("action", "", 0, "", next_action, last_action)
	if is_skill:
		_sound("cast", next_action)
	next_action += 1
	hero_pose = "skill" if is_skill else "attack"
	hero_pose_time = 0

func guard() -> bool:
	if state != "battle" or paused or guard_cd > 0 or move_clock > 0:
		return false
	guard_left = .7
	guard_cd = 2.5
	_emit("guard", "Thủ thế", 0, "guard_ready")
	return true

func _hit(amount: float, can_crit: bool, source: String = "weapon", action_id: int = 0) -> void:
	if state != "battle" or enemy_hp <= 0:
		return
	if source == "weapon":
		if has_trait("execute") and enemy_hp / enemy_max < .35: amount *= 1.2
		if empowered > 0:
			amount *= 1.3
			empowered = 0
		if marked:
			amount *= 1.2
			marked = false
		if has_trait("spring") and not last_action.get("skill", false): sp = minf(100, sp + 2)
	var critical: bool = can_crit and rng.randf() < stats.crit
	if critical:
		amount *= 1.6
	# Own elemental/resistance formulas, not recovered original formulas.
	var advantage := {"fire": "nature", "nature": "water", "water": "fire", "light": "dark", "dark": "light"}
	if advantage.get(stats.get("element", "light")) == stage.get("element"):
		amount *= 1.2
	amount = maxf(1, amount - int(stage.get("base_stage", run.stage)) * 1.5)
	if shield:
		amount *= .7 if (source == "weapon" and has_trait("pierce")) or (source == "assist" and stats.get("assist_rank", 1) >= 2) else .35
	enemy_hp = maxf(0, enemy_hp - amount)
	enemy_hurt = .16
	var cue := "critical" if critical else ("arrow_hit" if source == "assist" else "impact_" + str(stats.weapon).get_slice("_", 0))
	var visual: Dictionary = last_action.duplicate(true) if last_action.get("id", -1) == action_id else {}
	visual.source = source
	_emit("critical" if critical else "hit", "%d%s" % [amount, "!" if critical else ""], 1, cue, action_id, visual)
	if enemy_hp <= 0:
		kills += 1
		_sound("enemy_down", action_id)
		actions.clear()
		if wave == wave_count() - 1:
			state = "won"
			hero_pose = "idle"
			_emit("result", "CHIẾN THẮNG", 0, "victory")
		else:
			wave += 1
			move_clock = .8
			hero_pose = "run"
			hero_pose_time = 0

func _take_damage(amount: float) -> void:
	last_enemy_strike = time
	amount = maxf(1, amount - stats.defense)
	if guard_left > 0:
		amount *= .2
		if has_trait("riposte"): empowered = 4
		_emit("guard", "Đỡ đòn", 0, "guard_hit")
	var absorbed := minf(barrier, amount)
	barrier -= absorbed
	amount -= absorbed
	if absorbed > 0 and guard_left <= 0: _emit("guard", "Khiên hấp thụ", 0, "guard_hit")
	if amount <= 0: return
	hp = maxf(0, hp - amount)
	hurt_left = .25
	_emit("hurt", "−%d" % amount, 0, "hurt" if guard_left <= 0 else "")
	if hp <= 0:
		state = "lost"
		hero_pose = "death"
		hero_pose_time = 0
		actions.clear()
		_emit("result", "HÃY THỬ LẠI", 0, "defeat")

func _sound(cue: String, action_id: int = 0) -> void:
	_emit("sound", "", 0, cue, action_id)

func _emit(kind: String, text: String, target: int, cue: String = "", action_id: int = 0, visual: Dictionary = {}) -> void:
	visual = visual.duplicate(true)
	visual.presentation_wave = 2 if is_boss() else wave % 2
	event_sequence += 1
	events.append({"id": event_sequence, "kind": kind, "text": text, "target": target, "time": time, "cue": cue, "action_id": action_id, "wave": wave, "visual": visual.duplicate(true)})
	if events.size() > 128:
		events.pop_front()

func warning() -> String:
	if state != "battle" or move_clock > 0:
		return ""
	if is_boss():
		if stage.mechanic == "counter" and enemy_clock >= 2:
			return "PHẢN ĐÒN · Ngưng kỹ năng, chuẩn bị thủ thế"
		if shield:
			return "KHIÊN · Kiếm quang hoặc Tinh linh để phá" if variant("breaker") else "KHIÊN · Tinh linh có thể phá khiên"
	if enemy_clock >= 2:
		return "BOSS TỤ LỰC · Bấm Thủ thế!" if is_boss() else "Quái chuẩn bị đánh"
	if barrier > 0: return "KHIÊN BẢO HỘ · %d HP · %.1fs" % [barrier, barrier_left]
	if empowered > 0: return "NHẬT QUANG · Đòn tiếp theo +30%"
	if marked: return "DẤU ASH · Đòn tiếp theo +20%"
	return ""
