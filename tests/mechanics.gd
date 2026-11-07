extends SceneTree

const Catalog = preload("res://game/core/catalog.gd")
const Store = preload("res://game/core/progress.gd")
const Battle = preload("res://game/core/battle.gd")

func _initialize() -> void:
	var book := Catalog.new()
	DirAccess.make_dir_recursive_absolute("user://first_light_tests")
	var store := Store.new(book, "user://first_light_tests/mechanics_%d.json" % Time.get_ticks_usec())
	var stats: Dictionary = book.stats(store.profile)
	var run := {"id": "mechanics", "stage": 1, "seed": 123, "stats": stats}
	var guarded := Battle.new(book)
	guarded.start(run)
	var plain := Battle.new(book)
	plain.start(run)
	guarded.guard()
	guarded._take_damage(100)
	plain._take_damage(100)
	assert(guarded.hp > plain.hp)
	plain._take_damage(99999)
	assert(plain.state == "lost")
	var shield := Battle.new(book)
	run.stage = 2
	shield.start(run)
	shield.wave = 2
	shield._spawn()
	shield.advance(.02)
	assert(shield.shield)
	var before: float = shield.enemy_hp
	shield._hit(100, false)
	var reduction: float = before - shield.enemy_hp
	shield.shield = false
	before = shield.enemy_hp
	shield._hit(100, false)
	assert(before - shield.enemy_hp > reduction * 2.5)
	shield._spawn()
	shield.advance(.02)
	shield.auto_attack = false
	assert(shield.skill(2))
	for i in range(34):
		shield.advance(1.0 / 60)
	assert(shield.shield_broken and not shield.shield)
	var counter := Battle.new(book)
	run.stage = 3
	counter.start(run)
	counter.wave = 2
	counter._spawn()
	counter.auto_attack = false
	counter.enemy_clock = 2.1
	var hp_before: float = counter.hp
	counter.skill(0)
	for i in range(20):
		counter.advance(1.0 / 60)
	assert(counter.hp < hp_before)
	# Strong fixture isolates content completion from progression/balance.
	for hero in book.data.heroes:
		var profile: Dictionary = store.profile.duplicate(true)
		profile.hero = hero.id
		profile.heroes[hero.id].level = 15
		for stage in book.data.stages:
			var battle := Battle.new(book)
			battle.start({"id": "all-content", "stage": stage.id, "seed": 7, "stats": book.stats(profile)})
			for tick in range(24000):
				if battle.enemy_clock > 2.45:
					battle.guard()
				if battle.hp < battle.stats.hp * .6:
					battle.skill(1)
				elif battle.warning().begins_with("PHẢN"):
					pass
				else:
					battle.skill(2)
					battle.skill(0)
				battle.advance(1.0 / 60)
				if battle.state != "battle":
					break
			assert(battle.state == "won", "%s stage %s" % [hero.id, stage.id])
	print("PASS: guard, defeat, shield reduction, shield break, counter, 15 hero/stage combinations")
	quit()
