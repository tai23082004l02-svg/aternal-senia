extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var book := GameCatalog.new()
	var store := ProgressStore.new(book,"user://first_light_tests/exhibition_%d.json" % Time.get_ticks_usec())
	var before := store.profile.duplicate(true)
	var bytes := FileAccess.get_file_as_bytes(store.path)
	for roster in [[["eira"],["ryn"]],[["eira","ryn","mira","caelan"],["lyra","caelan","mira","eira"]],[["mira"],["mira"]]]:
		var a := ArenaExhibition.new(book)
		var b := ArenaExhibition.new(book)
		assert(a.start_match(store.profile,roster,17,3,true))
		assert(b.start_match(store.profile,roster,17,3,true))
		b.speed = 2
		for i in range(12000):
			a.advance(1.0/60)
			b.advance(1.0/120)
			assert(a.teams == b.teams and a.events == b.events)
			for unit in a.teams[0]+a.teams[1]:
				assert(unit.hp >= 0 and unit.hp <= unit.stats.hp and unit.pos == a._clamp(unit.pos))
			if a.state != "battle": break
		assert(a.state == "won" and a.winner in [-1,0,1])
		assert(a.events.any(func(e): return e.kind == "action"))
		assert(store.profile == before and FileAccess.get_file_as_bytes(store.path) == bytes)
	var invalid := ArenaExhibition.new(book)
	assert(not invalid.start_match(store.profile,[[],["ryn"]],17))
	assert(not invalid.start_match(store.profile,[["eira","eira"],["ryn"]],17))
	assert(not invalid.start_match(store.profile,[["selena_preview"],["ryn"]],17))
	print("PASS: RAM-only 1v1/4v4/mirror AI matches, skills/termination, seed/x2, bounded HP/positions, invalid setup and unchanged profile/file")
	quit()
