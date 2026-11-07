extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var book := GameCatalog.new()
	var store := ProgressStore.new(book, "user://first_light_tests/skill_fx_%d.json" % Time.get_ticks_usec())
	for speed in [1, 2, 3]:
		for skill in range(3):
			var battle := BattleModel.new(book)
			battle.start({"id": "skill_%d_%d" % [skill, speed], "stage": 1, "seed": 123, "stats": book.stats(store.profile)})
			battle.wave = 2
			battle._spawn()
			battle.auto_attack = false
			battle.speed = speed
			battle.hp = 80
			assert(battle.skill(skill))
			var marker: float = battle.last_action.marker
			if skill == 2:
				assert(CombatPresentation.hero(battle, battle.time).state == "idle", "Spirit cast must not play hero skill pose")
			var effects := CombatEffects.new()
			var kind: String = ["radiant_release", "restoration_release", "spirit_release"][skill]
			var release_seen := false
			for tick in range(ceili((marker + .15) * 60 / speed)):
				battle.advance(BattleModel.STEP)
				var before := [battle.hp, battle.enemy_hp, battle.sp, battle.rng.state, battle.events.duplicate(true)]
				effects.consume(battle, battle.time)
				assert(before == [battle.hp, battle.enemy_hp, battle.sp, battle.rng.state, battle.events])
				var count := 0
				for item in effects.items:
					if item.kind == kind:
						count += 1
						assert(item.start >= marker - .001, "Release cannot precede the hit marker")
						assert(item.event.target == (0 if skill == 1 else 1))
				assert(count <= 1, "One release per real skill event")
				if battle.time < marker: assert(count == 0)
				release_seen = release_seen or count == 1
			assert(release_seen)
			battle.paused = true
			var emitted := effects.emitted
			var items := effects.items.duplicate(true)
			var frozen: float = effects.now
			for i in range(20):
				battle.advance(.1)
				effects.consume(battle, battle.time)
			assert(effects.emitted == emitted and effects.items == items and effects.now == frozen)
			battle.paused = false
			for i in range(120):
				battle.advance(BattleModel.STEP)
				effects.consume(battle, battle.time)
			for item in effects.items:
				assert(item.kind != kind, "Skill releases expire")
			effects.reset("next_run")
			assert(effects.items.is_empty())
	print("PASS: three skill releases × three speeds, real markers, target, pause, dedupe, expiry and read-only simulation")
	quit()
