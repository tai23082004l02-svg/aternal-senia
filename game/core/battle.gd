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
var hero_pose := "idle"
var hero_pose_time := 0.0
var hurt_left := 0.0
var enemy_hurt := 0.0
var assist_flash := 0.0
var notice := ""

func _init(book: GameCatalog) -> void:
	catalog = book

func start(pending: Dictionary) -> void:
	run = pending.duplicate(true)
	stats = run.stats.duplicate(true)
	stage = catalog.find_row("stages", run.stage)
	rng.seed = int(run.seed)
	hp = stats.hp
	sp = 100.0
	wave = 0
	kills = 0
	time = 0
	cooldowns = [0.0, 0.0, 0.0]
	actions.clear()
	events.clear()
	state = "battle"
	_spawn()

func _spawn() -> void:
	enemy_max = float(stage.boss_hp) if wave == 2 else float(stage.enemy_hp) * (1.0 + wave * 0.35)
	enemy_hp = enemy_max
	enemy_clock = 0.0
	attack_clock = 0.0
	shield_broken = false
	shield = false
	hero_pose = "idle"
	hero_pose_time = 0
	_emit("wave", "BOSS · " + stage.boss if wave == 2 else "Đợt %d / 3" % (wave + 1), 0)

func advance(delta: float) -> void:
	if paused or state != "battle":
		return
	accumulator += minf(delta, 0.25) * speed
	while accumulator >= STEP and state == "battle":
		accumulator -= STEP
		_step()

func _step() -> void:
	time += STEP
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
		move_clock -= STEP
		hero_pose = "run"
		if move_clock <= 0:
			_spawn()
		return
	if hero_pose_time > 0.7 and actions.is_empty():
		hero_pose = "idle"
	attack_clock += STEP
	assist_clock += STEP
	enemy_clock += STEP
	shield = wave == 2 and stage.mechanic == "shield" and not shield_broken and fmod(enemy_clock, 5.0) < 2.8
	if auto_attack and attack_clock >= 0.85 and actions.is_empty():
		attack()
	var companion := catalog.find_row("assists", stats.assist)
	if assist_clock >= companion.interval:
		assist_clock = 0
		assist_flash = .5
		if stats.assist == "lumi":
			var heal: float = stats.hp * companion.power * (1 + (stats.assist_level - 1) * .12)
			hp = minf(stats.hp, hp + heal)
			_emit("heal", "+%d" % heal, 0)
		else:
			_hit(stats.atk * companion.power * (1 + (stats.assist_level - 1) * .15), false)
	if state != "battle" or move_clock > 0:
		return
	# Iterate all crossed markers; damage belongs to simulation, never the view.
	for action in actions.duplicate():
		action.elapsed += STEP
		if not action.hit and action.elapsed >= action.marker:
			action.hit = true
			if action.wave == wave:
				if action.kind == "heal":
					var healed: float = stats.hp * action.power * (1.25 if stats.hero == "mira" else 1.0)
					hp = minf(stats.hp, hp + healed)
					_emit("heal", "+%d" % healed, 0)
				else:
					if action.burst:
						shield_broken = true
						shield = false
					var counter: bool = wave == 2 and stage.mechanic == "counter" and enemy_clock >= 2.0 and action.skill
					_hit(stats.atk * action.power, true)
					if counter and state == "battle" and move_clock <= 0:
						_take_damage(stage.boss_atk * .65)
						_emit("warning", "Phản đòn!", 1)
		if action.elapsed >= action.duration:
			actions.erase(action)
		if state != "battle" or move_clock > 0:
			break
	if state == "battle" and move_clock <= 0 and enemy_clock >= 3.0:
		enemy_clock = 0
		var damage := float(stage.boss_atk) if wave == 2 else float(stage.enemy_atk)
		if wave == 2 and stage.mechanic == "smash":
			damage *= 1.5
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
	if sp < def.cost:
		return false
	sp -= def.cost
	cooldowns[index] = def.cd * stats.get("cooldown_scale", 1.0)
	var power: float = def.power * (1 + (stats.skills[index] - 1) * .12)
	if def.kind == "damage":
		power *= stats.skill_bonus
	_schedule(def.kind, power, def.hit, def.duration, true, index == 2)
	return true

func _schedule(kind: String, power: float, marker: float, duration: float, is_skill: bool, burst: bool) -> void:
	actions.append({"id": next_action, "elapsed": 0.0, "hit": false, "wave": wave, "marker": marker, "duration": duration, "kind": kind, "power": power, "skill": is_skill, "burst": burst})
	next_action += 1
	hero_pose = "skill" if is_skill else "attack"
	hero_pose_time = 0

func guard() -> bool:
	if state != "battle" or paused or guard_cd > 0 or move_clock > 0:
		return false
	guard_left = .7
	guard_cd = 2.5
	_emit("guard", "Thủ thế", 0)
	return true

func _hit(amount: float, can_crit: bool) -> void:
	if state != "battle" or enemy_hp <= 0:
		return
	var critical: bool = can_crit and rng.randf() < stats.crit
	if critical:
		amount *= 1.6
	# Own elemental/resistance formulas, not recovered original formulas.
	var advantage := {"fire": "nature", "nature": "water", "water": "fire", "light": "dark", "dark": "light"}
	if advantage.get(stats.get("element", "light")) == stage.get("element"):
		amount *= 1.2
	amount = maxf(1, amount - int(run.stage) * 1.5)
	if shield:
		amount *= .35
	enemy_hp = maxf(0, enemy_hp - amount)
	enemy_hurt = .16
	_emit("critical" if critical else "hit", "%d%s" % [amount, "!" if critical else ""], 1)
	if enemy_hp <= 0:
		kills += 1
		actions.clear()
		if wave == 2:
			state = "won"
			hero_pose = "idle"
			_emit("result", "CHIẾN THẮNG", 0)
		else:
			wave += 1
			move_clock = .8
			hero_pose = "run"

func _take_damage(amount: float) -> void:
	amount = maxf(1, amount - stats.defense)
	if guard_left > 0:
		amount *= .2
		_emit("guard", "Đỡ đòn", 0)
	hp = maxf(0, hp - amount)
	hurt_left = .25
	_emit("hurt", "−%d" % amount, 0)
	if hp <= 0:
		state = "lost"
		hero_pose = "death"
		hero_pose_time = 0
		actions.clear()
		_emit("result", "HÃY THỬ LẠI", 0)

func _emit(kind: String, text: String, target: int) -> void:
	event_sequence += 1
	events.append({"id": event_sequence, "kind": kind, "text": text, "target": target, "time": time})
	if events.size() > 40:
		events.pop_front()

func warning() -> String:
	if state != "battle" or move_clock > 0:
		return ""
	if wave == 2:
		if stage.mechanic == "counter" and enemy_clock >= 2:
			return "PHẢN ĐÒN · Ngưng kỹ năng, chuẩn bị thủ thế"
		if shield:
			return "KHIÊN · Tinh linh có thể phá khiên"
	if enemy_clock >= 2:
		return "BOSS TỤ LỰC · Bấm Thủ thế!" if wave == 2 else "Quái chuẩn bị đánh"
	return ""
