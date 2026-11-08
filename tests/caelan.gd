extends SceneTree
var book := GameCatalog.new()
func write(path: String,p: Dictionary) -> void:
	var f := FileAccess.open(path,FileAccess.WRITE)
	f.store_string(JSON.stringify(p,"",true,true))
	f.close()
func _initialize() -> void: call_deferred("run")
func run() -> void:
	assert(book.errors.is_empty() and book.data.heroes.size() == 5)
	var dir := "user://first_light_tests/caelan_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(dir)
	var legacy_book := GameCatalog.new()
	legacy_book.data.heroes = legacy_book.data.heroes.filter(func(h): return h.id != "caelan")
	var source := ProgressStore.new(legacy_book,dir.path_join("old-source.json"))
	var p := source.profile.duplicate(true)
	p.cleared = [1,2,3]
	p.gold = 4321
	p.training = AttributeTraining.fresh(legacy_book)
	p.evolution = HeroEvolution.fresh(legacy_book)
	p.outfits = Wardrobe.fresh(legacy_book)
	p.recruitment = Recruitment.fresh(legacy_book)
	p.recruitment.fragments.ryn = 27
	p.heroes.ryn.level = 12
	assert(source.commit(p) and source.begin_run(1))
	p = source.profile.duplicate(true)
	p.version = 12
	for unit in p.pending.team.units:
		var id: String = unit.stats.hero
		unit.stats.combat = {"basic":"adaptive_heal" if id == "mira" else "damage","ultimate":"team_heal" if id == "mira" else "damage","damage_taken":.9 if id == "ryn" else 1.0,"ultimate_shield":id == "ryn"}
	p.pending.stats = p.pending.team.units[0].stats.duplicate(true)
	p = GameCatalog.normalize(p)
	var path := dir.path_join("v12.json")
	write(path,p)
	var bytes := FileAccess.get_file_as_bytes(path)
	var three := p.duplicate(true)
	three.pending.team.version = 1
	three.pending.team.units = three.pending.team.units.slice(0,3)
	write(dir.path_join("v12-team-v1.json"),three)
	var old_three := ProgressStore.new(book,dir.path_join("v12-team-v1.json"))
	assert(not old_three.read_only and old_three.profile.pending == three.pending)
	var singleton := p.duplicate(true)
	singleton.pending.erase("team")
	write(dir.path_join("v12-singleton.json"),singleton)
	var old_single := ProgressStore.new(book,dir.path_join("v12-singleton.json"))
	assert(not old_single.read_only and old_single.profile.pending == singleton.pending)
	var store := ProgressStore.new(book,path)
	assert(not store.read_only and store.profile.version == 13)
	assert(store.profile.pending == p.pending and store.profile.gold == p.gold and store.profile.items == p.items)
	assert(store.profile.heroes.ryn == p.heroes.ryn and store.profile.recruitment.fragments.ryn == 27)
	assert(not store.available_hero("caelan") and store.profile.heroes.caelan.equipment.weapon == "")
	assert(not Recruitment.recruit_caelan(store)) # Pending guard.
	assert(store.settle(store.profile.pending.id,false,0))
	assert(FileAccess.get_file_as_bytes(path+".bak") == bytes)
	var before := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not Recruitment.recruit_caelan(store) and store.profile == before)
	store.fail_writes = false
	assert(Recruitment.recruit_caelan(store) and not Recruitment.recruit_caelan(store))
	assert(store.profile.gold == before.gold and store.profile.items == before.items)
	assert(ProgressStore.new(book,path).available_hero("caelan"))
	var broken := p.duplicate(true)
	broken.heroes.erase("ryn")
	write(dir.path_join("broken.json"),broken)
	assert(ProgressStore.new(book,dir.path_join("broken.json")).read_only)
	var future := p.duplicate(true)
	future.version = 14
	write(dir.path_join("future.json"),future)
	assert(ProgressStore.new(book,dir.path_join("future.json")).read_only)
	# A partial squad uses four slots while preserving the original three-unit test.
	p = store.profile.duplicate(true)
	p.hero = "caelan"
	p.formation = {"slots":["caelan","ryn","lyra",""],"auto_ult":false,"auto_next":false}
	assert(store.commit(p) and store.begin_run(1))
	var model := TeamBattle.new(book)
	model.start(store.profile.pending)
	model.enemies[0].hp = 100000
	model.enemies[0].max_hp = 100000
	model.allies[1].hp *= .4
	model._basic(model.allies[0])
	model.time = .51
	model._advance_ally(model.allies[0])
	assert(model.allies[1].barrier > 0 and model.allies[0].barrier == 0)
	model.allies[0].action = {}
	model.allies[0].energy = 100
	assert(model.ultimate(0))
	model.time += .51
	model._advance_ally(model.allies[0])
	for ally in model.allies: assert(ally.barrier >= ally.stats.hp*.22)
	model.allies[1].barrier = 0
	model._basic(model.allies[1])
	model.time += .51
	model._advance_ally(model.allies[1])
	assert(is_equal_approx(model.allies[1].barrier,model.allies[1].stats.hp*.08))
	assert(is_equal_approx(model._hero_combat(model.allies[2]).basic_cooldown,4.3))
	var extra: Dictionary = model.encounter_data.waves[0].units[0].duplicate(true)
	extra.hp = 100000
	model._add_enemy(extra)
	model.enemies[0].hp = 30000
	model.allies[2].energy = 100
	assert(model.ultimate(2))
	var target_before: float = model.enemies[0].hp
	var lyra_before: float = model.allies[2].hp
	var other_before: float = model.enemies[1].hp
	model.time += .51
	model._advance_ally(model.allies[2])
	assert(model.enemies[0].hp < target_before and model.allies[2].hp == lyra_before and model.enemies[1].hp == other_before)
	for ally in model.allies: ally.barrier = 0
	var protected_hp: float = model.allies[1].hp
	var expected: float = maxf(1,100-model.allies[1].stats.defense)*(1-model.allies[1].stats.damage_reduction)*.9*.88
	model._damage_ally(1,100,0)
	assert(is_equal_approx(protected_hp-model.allies[1].hp,expected))
	model.allies[2].stats.crit = 0
	model.allies[2].stats.weapon_trait = ""
	model.enemies[0].max_hp = 50000.0
	model.enemies[0].hp = 10000
	model._damage_enemy(0,100,model.allies[2],true)
	var low_damage: float = 10000-model.enemies[0].hp
	model.enemies[0].max_hp = 20000.0
	model.enemies[0].hp = 10000
	model._damage_enemy(0,100,model.allies[2],true)
	var high_damage: float = 10000-model.enemies[0].hp
	assert(is_equal_approx((low_damage+1.5)/(high_damage+1.5),1.35))
	assert(store.settle(store.profile.pending.id,false,0))
	p = store.profile.duplicate(true)
	p.cleared = [1,2,3,4,5]
	assert(store.commit(p) and store.begin_run(103))
	var run_id: String = store.profile.pending.id
	var count_before: int = store.profile.recruitment.fragments.caelan
	var pending_before := store.profile.duplicate(true)
	store.fail_writes = true
	assert(not store.settle(run_id,true,0) and store.profile == pending_before)
	store.fail_writes = false
	assert(store.settle(run_id,true,0))
	assert(store.profile.recruitment.fragments.caelan == count_before+2)
	assert(store.settle(run_id,true,0) and store.profile.recruitment.fragments.caelan == count_before+2)
	var starter := ProgressStore.new(book,dir.path_join("starter.json"))
	var starter_profile := starter.profile.duplicate(true)
	starter_profile.cleared = [1,2,3]
	assert(starter.commit(starter_profile) and Recruitment.recruit_caelan(starter))
	assert(starter.equip(starter.profile.items[0].uid,"caelan"))
	starter_profile = starter.profile.duplicate(true)
	starter_profile.hero = "caelan"
	starter_profile.formation = {"slots":["caelan","ryn","lyra","eira"],"auto_ult":true,"auto_next":false}
	assert(starter.commit(starter_profile) and starter.begin_run(1))
	var real := TeamBattle.new(book)
	real.start(starter.profile.pending)
	for tick in range(12000):
		real.advance(1.0/60)
		if real.state != "battle": break
	assert(real.state == "won" and real.allies.size() == 4)
	assert(starter.settle(starter.profile.pending.id,true,real.kills,real.time))
	var frames := FrameLibrary.new()
	var unique := {}
	for clip in frames.manifest.heroes.caelan.values():
		for frame in clip.frames:
			unique[frame.file] = true
			var tex: AtlasTexture = frames.textures[frame.file]
			assert(tex.region.end.x <= 1254 and tex.region.end.y <= 1254)
	assert(unique.size() == 16)
	print("PASS: Caelan v12-to-v13 preserved pending/UIDs/investment/backup, guarded free recruitment, five-hero maps, Vanguard shields, Ryn/Lyra kits and 16 source poses")
	quit()
