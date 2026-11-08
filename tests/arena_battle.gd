extends SceneTree
var book := GameCatalog.new()
var pending: Dictionary
var store: ProgressStore
func _initialize() -> void: call_deferred("run")
func model() -> ArenaBattle:
	var battle := ArenaBattle.new(book)
	battle.start(pending)
	return battle
func run() -> void:
	var dir := "user://first_light_tests/arena_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	store = ProgressStore.new(book, dir.path_join("save.json"))
	var p := store.profile.duplicate(true)
	p.cleared = [1,2,3,4,5]
	p.hero = "eira"
	p.formation = {"slots":["eira","mira","ryn","lyra"],"auto_ult":true,"auto_next":false}
	assert(store.commit(p) and store.begin_run(6))
	var legacy_profile: Dictionary = store.profile.duplicate(true)
	legacy_profile.pending.team.version = 3
	assert(store.commit(legacy_profile))
	pending = store.profile.pending.duplicate(true)
	pending.team.version = 3
	assert(pending.team.version == 3 and Formation.valid_snapshot(store, pending.team))
	assert(ProgressStore.new(book, store.path).profile.pending == pending)
	var invalid: Dictionary = pending.team.duplicate(true)
	invalid.version = 5
	assert(not Formation.valid_snapshot(store, invalid))
	var battle := model()
	var first := battle.allies[0].pos as Vector2
	var hp_before: float = battle.enemies[0].hp
	battle.advance(.25)
	assert(battle.allies[0].pos != first and battle.enemies[0].hp == hp_before, "Approach before dealing damage")
	# Target proximity replaces slot-priority; explicit focus still overrides AI.
	battle = model()
	battle.allies[0].pos = Vector2(60,120)
	battle.allies[3].pos = battle.enemies[0].pos - Vector2(40,0)
	assert(battle._enemy_target(battle.enemies[0]) == 3)
	battle.enemies[1].pos = battle.allies[0].pos + Vector2(40,0)
	assert(battle._ally_target(battle.allies[0]) == 1)
	assert(battle.select_target(2) and battle._ally_target(battle.allies[0]) == 2)
	battle.enemies[2].hp = 0
	assert(battle._ally_target(battle.allies[0]) == 1)
	# Whiff at marker: no remote melee damage, no cooldown burned approaching.
	battle = model()
	var ally: Dictionary = battle.allies[0]
	battle._basic(ally)
	assert(ally.basic_cd == 0 and ally.action.is_empty())
	ally.pos = battle.enemies[0].pos - Vector2(45,0)
	battle._schedule_ally(ally,"attack",1,.22,.52)
	assert(not ally.action.is_empty())
	battle.enemies[0].pos = Vector2(48,120)
	hp_before = battle.enemies[0].hp
	battle.time = .23
	battle._advance_ally(ally)
	assert(battle.enemies[0].hp == hp_before)
	assert(battle.events.any(func(e): return e.kind == "miss"))
	# A target that circles behind the committed melee direction also avoids it.
	battle = model()
	ally = battle.allies[0]
	ally.pos = Vector2(260,230)
	battle.enemies[0].pos = Vector2(305,230)
	battle._schedule_ally(ally,"attack",1,.22,.52)
	battle.enemies[0].pos = Vector2(215,230)
	hp_before = battle.enemies[0].hp
	battle.time = .23
	battle._advance_ally(ally)
	assert(battle.enemies[0].hp == hp_before)
	# Spatial enemy ground attack: only heroes still inside the committed area hit.
	battle = model()
	var enemy: Dictionary = battle.enemies[0]
	for unit in battle.allies: unit.pos = Vector2(48,120)
	battle.allies[0].pos = Vector2(260,230)
	enemy.action = {"target":0,"point":Vector2(260,230),"radius":38.0,"hit":false,"id":1,"started":0.0,"marker":.35}
	var health: float = battle.allies[0].hp
	battle.allies[0].pos = Vector2(48,120)
	battle._resolve_enemy_action(enemy)
	assert(battle.allies[0].hp == health)
	battle.allies[1].pos = Vector2(260,230)
	health = battle.allies[1].hp
	battle._resolve_enemy_action(enemy)
	assert(battle.allies[1].hp < health)
	# Idle AI leaves a warned area; no invulnerability is granted by movement.
	battle = model()
	enemy = battle.enemies[0]
	enemy.pos = Vector2(300,230)
	ally = battle.allies[0]
	ally.pos = Vector2(260,230)
	enemy.action = {"target":0,"point":ally.pos,"radius":38.0,"hit":false,"id":1,"started":0.0,"marker":.35}
	battle.time = .12
	for i in range(24):
		battle._move_units()
		battle.time += BattleModel.STEP
	assert(ally.pos.distance_to(enemy.action.point) > 38)
	# Ranged AI backs off and magic has travel time, independent of renderer.
	battle = model()
	ally = battle.allies[1]
	ally.pos = Vector2(240,230)
	for e in battle.enemies: e.pos = Vector2(360,230)
	first = ally.pos
	battle._move_units()
	assert(ally.pos.x < first.x)
	ally.action = {"kind":"attack"}
	hp_before = battle.enemies[0].hp
	battle._damage_enemy(0,100,ally,false)
	assert(battle.enemies[0].hp == hp_before and battle.projectiles.size() == 1)
	for i in range(40): battle._step_projectiles()
	assert(battle.enemies[0].hp < hp_before and battle.projectiles.is_empty())
	# Manual Ultimate queued outside range casts after approaching with AUTO off.
	battle = model()
	battle.auto_ultimate = false
	ally = battle.allies[3]
	ally.energy = 100
	assert(battle.ultimate(3) and ally.ultimate_queued and ally.energy == 100)
	for i in range(180): battle.advance(1.0/60)
	assert(not ally.ultimate_queued and ally.energy < 100)
	# Switching AUTO off cancels its future casts, without a hidden manual queue.
	battle = model()
	ally = battle.allies[3]
	ally.energy = 100
	battle.advance(1.0/60)
	assert(not ally.ultimate_queued and ally.energy == 100)
	battle.auto_ultimate = false
	for i in range(180): battle.advance(1.0/60)
	assert(ally.energy == 100 and not ally.ultimate_queued)
	# Fixed seed, x1/x2 and resume reproduce positions, HP, events and outcomes.
	var a := model()
	var b := model()
	b.speed = 2
	for i in range(12000):
		a.advance(1.0/60)
		b.advance(1.0/120)
		for unit in a.allies + a.enemies:
			assert(unit.pos.is_finite() and unit.pos == a._clamp(unit.pos))
		assert(a.allies == b.allies and a.enemies == b.enemies and a.projectiles == b.projectiles and a.events == b.events)
		if a.state != "battle": break
	assert(a.state in ["won","lost"] and a.state == b.state)
	assert(a.kills <= Formation.kill_cap(pending.team.encounter))
	assert(store.settle(pending.id,a.state == "won",a.kills,a.time))
	var rewarded := store.profile.duplicate(true)
	assert(store.settle(pending.id,a.state == "won",a.kills,a.time) and store.profile == rewarded)
	battle = model()
	battle.advance(1)
	battle.paused = true
	var frozen := battle.allies.duplicate(true)
	var clock := battle.time
	battle.advance(.5)
	assert(battle.allies == frozen and battle.time == clock)
	# Historical snapshots are valid and still run the non-spatial legacy model.
	for version in [1,2]:
		var old := pending.duplicate(true)
		old.team.version = version
		if version == 1: old.team.units.pop_back()
		assert(Formation.valid_snapshot(store, old.team))
		var legacy := TeamBattle.new(book)
		legacy.start(old)
		legacy.advance(.5)
		assert(not legacy.allies[0].has("pos") and legacy.run == old)
	print("PASS: arena approach/range/nearest target/focus, telegraph escape/hits, ranged retreat/projectiles, bounds, seed/x2/resume, atomic rewards and legacy v1/v2")
	quit()
