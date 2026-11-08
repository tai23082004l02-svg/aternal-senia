extends SceneTree
var game
var output := "user://first_light_previews/supplies"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/supplies_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func settle() -> void:
	for i in range(4): await process_frame

func capture(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	var picture := root.get_texture().get_image()
	assert(picture.save_png(output.path_join(name+".png")) == OK)
	if name in ["supplies-list","supplies-chest","supplies-support","supplies-stone"]:
		print("SUPPLIES_REVIEW:"+name+":"+Marshalls.raw_to_base64(picture.save_jpg_to_buffer(.7)))

func run() -> void:
	if not OS.get_environment("FIRST_LIGHT_CAPTURE_DIR").is_empty(): output = OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output)
	var source := Image.load_from_file("res://art/supplies/icons.png")
	assert(source != null and source.get_size()==Vector2i(1536,1024))
	print("SUPPLIES_ALPHA:",source.detect_alpha(),":corner=",source.get_pixel(0,0).a)
	assert(source.detect_alpha()!=Image.ALPHA_NONE,"Icon source needs real transparency")
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await settle()
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 10000
	p.cleared = [1,2,3]
	for id in Supplies.ORDER: p.supplies.counts[id] = 6
	p.supplies.counts.normal_ticket = 10
	assert(game.store.commit(p))
	var original: Dictionary = game.store.profile.duplicate(true)
	game._supply_open("")
	await capture("supplies-list")
	for id in Supplies.ORDER:
		assert(game.panel.find_child("Supply_"+id,true,false)!=null)
	for group in ["consumable","upgrade","spirit","ticket","all"]:
		game._supply_filter(group)
		await settle()
		assert(game.store.profile==original)
	for id in Supplies.ORDER:
		game._supply_open(id)
		await settle()
		assert(game.store.profile==original)
		for control in game.panel.find_children("*","Button",true,false):
			assert(control.get_global_rect().end.x<=540,"Supply actions fit the mobile viewport")
	game._supply_open("forge_stone")
	await capture("supplies-stone")
	var uid: String = game.store.profile.items[0].uid
	game._supply_confirm("stone",uid,0)
	game._close_modal()
	assert(game.store.profile==original,"Cancel cannot spend")
	game.store.fail_writes = true
	game._supply_execute("stone",uid,0)
	assert(game.store.profile==original)
	game.store.fail_writes = false
	game._supply_execute("stone",uid,0)
	assert(game.store.profile.supplies.counts.forge_stone==original.supplies.counts.forge_stone-1)
	assert(EquipmentSystem.item_for(game.store.profile,uid).enhance==1)
	game._supply_open("material_chest")
	await capture("supplies-chest")
	original = game.store.profile.duplicate(true)
	game._supply_confirm("chest","memory_shard",0)
	game._close_modal()
	assert(game.store.profile==original)
	game._supply_execute("chest","memory_shard",0)
	assert(game.store.profile.items==original.items and game.store.profile.supplies.counts.memory_shard==original.supplies.counts.memory_shard+2)
	game._supply_open("memory_shard")
	original = game.store.profile.duplicate(true)
	game._supply_hero("mira")
	assert(game.store.profile==original and game.store.profile.hero=="eira")
	game._supply_execute("train","mira",0)
	assert(game.store.profile.heroes.mira.skills[0]==original.heroes.mira.skills[0]+1)
	game._supply_open("normal_ticket")
	original = game.store.profile.duplicate(true)
	game._supply_execute("ticket","",1)
	assert(game.modal!=null and game.store.profile.gold==original.gold and game.store.profile.supplies.counts.normal_ticket==original.supplies.counts.normal_ticket-1)
	game._close_modal()
	game._supply_milestones()
	await capture("supplies-milestones")
	original = game.store.profile.duplicate(true)
	game._supply_execute("claim","story_1",0)
	assert(game.store.profile.supplies.counts.material_chest==original.supplies.counts.material_chest+1)
	game._supply_execute("claim","story_1",0)
	assert(game.store.profile.supplies.counts.material_chest==original.supplies.counts.material_chest+1)
	game._supply_open("rage_potion")
	original = game.store.profile.duplicate(true)
	game._supply_confirm("select","rage_potion",0)
	game._close_modal()
	assert(game.store.profile==original)
	game._supply_execute("select","rage_potion",0)
	assert(game.store.profile.supplies.selected=="rage_potion" and game.store.profile.supplies.counts.rage_potion==original.supplies.counts.rage_potion)
	await capture("supplies-support")
	game._supply_source("grove")
	assert(game.tab==21 and game.dungeon_selected=="grove")
	game._dungeon_enter("grove")
	assert(game.modal!=null)
	game._begin()
	assert(game.battle is TeamBattle and game.store.profile.supplies.selected=="")
	assert(game.store.profile.supplies.counts.rage_potion==original.supplies.counts.rage_potion-1)
	original = game.store.profile.duplicate(true)
	game._supply_open("material_chest")
	game._supply_execute("chest","memory_shard",0)
	assert(game.store.profile==original,"Pending battle protects all item usage")
	game._select_tab(0)
	assert(not game.battle.paused)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS:8-item art/UI, category/source navigation, mobile bounds, confirm/cancel/write rollback, per-UID upgrade, chest/skill/ticket/claims, one-run preparation and pending locks")
	quit()
