extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var book := GameCatalog.new()
	var path := "user://first_light_tests/tactics_%d.json" % Time.get_ticks_usec()
	var store := ProgressStore.new(book, path)
	var p := store.profile.duplicate(true)
	p.cleared = [1,2,3,4,5]
	p.hero = "eira"
	p.formation = {"slots":["eira","mira","ryn","lyra"],"auto_ult":true,"auto_next":false}
	assert(store.commit(p) and store.begin_run(6))
	var pending: Dictionary = store.profile.pending.duplicate(true)
	assert(pending.team.version == 4 and Formation.valid_snapshot(store, pending.team))
	for unit in pending.team.units:
		assert(unit.stats == GameCatalog.normalize(book.stats(p, unit.stats.hero)), "AI does not rewrite progression stats")
		assert(ArenaTactics.valid(unit.ai))
	var bad: Dictionary = pending.team.duplicate(true)
	bad.units[0].ai.reaction = 101
	assert(not Formation.valid_snapshot(store,bad))
	assert(ProgressStore.new(book,path).profile.pending == pending)
	var a := TacticalArenaBattle.new(book)
	var b := TacticalArenaBattle.new(book)
	a.start(pending)
	b.start(pending)
	b.speed = 2
	for i in range(12000):
		a.advance(1.0/60)
		b.advance(1.0/120)
		assert(a.allies == b.allies and a.enemies == b.enemies and a.events == b.events)
		if a.state != "battle": break
	assert(a.state in ["won","lost"])
	# Decisions never change skill cooldowns or damage/defense stats.
	a.start(pending)
	var ally: Dictionary = a.allies[0]
	var stats: Dictionary = ally.stats.duplicate(true)
	ally.ai.combo = 100
	ally.combo_pending = true
	ally.basic_cd = 3
	a._decide(ally)
	assert(ally.clock >= .55 and ally.basic_cd == 3 and ally.stats == stats)
	ally.ai.counter = 100
	ally.last_attacker = a.enemies[1].id
	ally.counter_pending = true
	a._decide(ally)
	assert(a._ally_target(ally) == 1 and ally.stats == stats)
	assert(a.select_target(2) and a._ally_target(ally) == 2)
	# Profile is frozen in the saved run, independent of later profile defaults.
	pending.team.units[0].ai.speed = 150
	a.start(pending)
	assert(a.allies[0].ai.speed == 150)
	print("PASS: frozen per-hero tactics, v4 validation/reload, unchanged progression stats/cooldowns, combo/counter/focus and seeded x1/x2")
	quit()
