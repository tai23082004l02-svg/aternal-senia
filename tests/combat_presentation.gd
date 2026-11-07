extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var book := GameCatalog.new()
	var store := ProgressStore.new(book, "user://first_light_tests/presentation_%d.json" % Time.get_ticks_usec())
	var library := FrameLibrary.new()
	for speed in [1, 2, 3]:
		var battle := BattleModel.new(book)
		battle.start({"id": "presentation_%d" % speed, "stage": 1, "seed": 123, "stats": book.stats(store.profile)})
		battle.auto_attack = false
		battle.speed = speed
		battle.advance(.25)
		battle.advance(.25)
		assert(battle.attack())
		var effects := CombatEffects.new()
		for tick in range(40):
			battle.advance(1.0 / 60)
			effects.consume(battle, battle.time)
		var snapshot := [battle.hp, battle.enemy_hp, battle.sp, battle.rng.state, battle.cooldowns.duplicate(), battle.events.duplicate(true)]
		var emitted := effects.emitted
		battle.paused = true
		var pose := CombatPresentation.hero(battle, battle.time)
		for repeat in range(100):
			battle.advance(.05)
			effects.consume(battle, battle.time)
			assert(CombatPresentation.hero(battle, battle.time) == pose)
		assert(effects.emitted == emitted)
		assert(snapshot == [battle.hp, battle.enemy_hp, battle.sp, battle.rng.state, battle.cooldowns, battle.events])
		effects.reset("new_run")
		assert(effects.items.is_empty() and effects.cursor == 0)
		for i in range(200):
			effects._add("impact", {"id": i, "time": 0}, 1, 0, speed)
		assert(effects.items.size() == CombatEffects.CAP)
	assert(is_equal_approx(CombatPresentation.lunge(.22, .22, .52), 64))
	assert(is_zero_approx(CombatPresentation.lunge(.52, .22, .52)))
	assert(library.motion_frame("eira", "attack", .22, .22, .52).file == "painted/eira_08")
	for marker in [.25, .35, .5]:
		var expected := library.motion_frame("eira", "skill", .5, .5, .95)
		assert(library.motion_frame("eira", "skill", marker, marker, .95).file == expected.file)
	for key in library.vfx_manifest.effects:
		var tex: AtlasTexture = library.textures["fx_" + key]
		assert(tex.region.end.x <= tex.atlas.get_width() and tex.region.end.y <= tex.atlas.get_height())
	print("PASS: x1/x2/x3 read-only presentation, pause, dedupe, bounded VFX, marker alignment and recovery")
	quit()
