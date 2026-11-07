extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var book := GameCatalog.new()
	var dir := "user://first_light_tests/team_matrix_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	var store := ProgressStore.new(book, dir.path_join("save.json"))
	var p := store.profile.duplicate(true)
	p.cleared = [1,2,3,4,5]
	for hero in book.data.heroes: p.heroes[hero.id].level = 8
	var configurations := [["ryn","mira","eira"],["eira","ryn","lyra"],["mira","lyra","eira"],["lyra","mira","ryn"]]
	var total := 0
	var won := 0
	for roster in configurations:
		p.hero = roster[0]
		p.formation = {"slots":roster,"auto_ult":true,"auto_next":false}
		p.assist = "ash" if roster == configurations[1] else "lumi"
		for stage in book.data.stages:
			var team := Formation.snapshot(book, p, stage)
			assert(Formation.valid_snapshot(store, team))
			var model := TeamBattle.new(book)
			model.start({"id":"matrix", "stage":stage.id,"seed":17,"stats":book.stats(p),"team":team})
			for i in range(12000):
				model.advance(1.0 / 60)
				assert(model.enemies.size() <= 4)
				if model.state != "battle": break
			assert(model.state in ["won","lost"])
			assert(model.kills <= Formation.kill_cap(team.encounter))
			for ally in model.allies:
				assert(ally.hp >= 0 and ally.hp <= ally.stats.hp)
				assert(ally.energy >= 0 and ally.energy <= 100)
				if ally.hp <= 0: assert(ally.action.is_empty())
			total += 1
			if model.state == "won": won += 1
	assert(total == 72)
	print("PASS: 72 team/encounter combinations terminate with bounded units, resources and kills; wins=", won)
	quit()
