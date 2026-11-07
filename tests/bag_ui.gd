extends SceneTree

var game
var output := "user://first_light_previews/bag"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/bag_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png")) == OK)

func run() -> void:
	if not OS.get_environment("FIRST_LIGHT_CAPTURE_DIR").is_empty(): output = OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 10000
	p.shards = 100
	p.xp = 300
	p.cleared = [1,2]
	p.expansion.cores = 12
	assert(game.store.commit(p))
	game._bag_open("")
	await capture("bag-home")
	game._bag_open("equipment")
	var original: Dictionary = game.store.profile.duplicate(true)
	game._bag_sort_next()
	game._bag_help()
	game._close_modal()
	assert(game.store.profile == original)
	game._select_tab(19)
	var quantity := game.panel.find_child("ForgeQuantity",true,false) as SpinBox
	assert(quantity != null)
	quantity.value = 3
	assert(game.forge_count == 3)
	await capture("bag-forge")
	game._forge_batch_confirm("sword_1")
	assert(game.store.profile == original, "Opening confirmation cannot spend resources")
	game._close_modal()
	game._forge_batch_execute("sword_1",3)
	assert(game.store.profile.items.size() == original.items.size()+3)
	assert(game.store.profile.gold == original.gold-195 and game.store.profile.shards == original.shards-9)
	var copies: Array = game.store.profile.items.filter(func(item): return item.base == "sword_1" and item.uid != "starter_eira")
	assert(copies.size() == 3)
	var target: String = copies[0].uid
	game._forge_tab(2)
	original = game.store.profile.duplicate(true)
	game._forge_fuse_confirm(target)
	await capture("bag-fusion-confirm")
	game._close_modal()
	assert(game.store.profile == original)
	game._forge_fuse_execute(target,game.store.fusion_donors(target))
	assert(EquipmentSystem.item_for(game.store.profile,target).rank == 2)
	game._bag_open("equipment")
	await capture("bag-equipment")
	game._bag_select_mode()
	game._bag_toggle_uid("starter_eira")
	assert(game.bag_selected.is_empty(), "Equipped copies cannot be bulk selected")
	game._bag_toggle_uid(target)
	game._bag_dismantle_confirm()
	original = game.store.profile.duplicate(true)
	game._close_modal()
	assert(game.store.profile == original)
	game._bag_dismantle_execute([target])
	assert(EquipmentSystem.item_for(game.store.profile,target).is_empty())
	game._bag_open("spirits")
	game._bag_spirit_select("ash")
	var previous: String = game.store.profile.assist
	var level: int = game.store.profile.assists.ash
	game._bag_upgrade_spirit("ash")
	assert(game.store.profile.assists.ash == level+1 and game.store.profile.assist == previous)
	game._assist("ash")
	assert(game.store.profile.assist == "ash")
	await capture("bag-spirits")
	game._bag_open("materials")
	await capture("bag-materials")
	original = game.store.profile.duplicate(true)
	game._bag_material_detail("weapon_category")
	game._close_modal()
	assert(game.store.profile == original)
	assert(game.store.begin_run(1))
	original = game.store.profile.duplicate(true)
	game._forge_batch_execute("sword_1",1)
	game._bag_upgrade_spirit("ash")
	game._bag_dismantle_execute(["starter_eira"])
	assert(game.store.profile == original, "Pending battle locks every new mutation")
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: inventory pages, batch quantity/cost, fusion/bulk confirmation cancellation, equipped protection, selected spirit upgrade, materials and pending locks")
	quit()
