extends SceneTree
var game
var output := "user://first_light_previews/equipment"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR", ProjectSettings.globalize_path("user://first_light_tests/equipment_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name + ".png")) == OK)

func item_uid(id: String) -> String:
	for item in game.store.profile.items:
		if item.base == id: return item.uid
	return ""

func button(prefix: String) -> Button:
	for node in game.panel.find_children("*", "Button", true, false):
		if node.text.begins_with(prefix): return node
	assert(false, prefix)
	return null

func run() -> void:
	if not OS.get_environment("FIRST_LIGHT_CAPTURE_DIR").is_empty(): output = OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 30000
	p.shards = 200
	p.cleared = [1,2,3]
	for def in game.catalog.data.items: game.store._add_item(p, def.id)
	for pair in [["eira", ["sword_dawn","armor_7","boots_7","accessory_7"]], ["ryn", ["spear_ember","armor_4","boots_4","accessory_4"]]]:
		for id in pair[1]:
			for item in p.items:
				if item.base == id:
					p.heroes[pair[0]].equipment[game.catalog.find_row("items", id).slot] = item.uid
					if id == "sword_dawn": item.enhance = 7
	assert(game.store.commit(p))
	game._bag_open("equipment")
	await capture("equipment-inventory")
	var filters: Array = game.panel.find_children("*", "OptionButton", true, false)
	assert(filters[0].item_count == 5 and filters[1].item_count == 6)
	for i in range(1, 5):
		game._bag_filter(i, false)
		await capture("equipment-slot-%d" % i)
	game._item_detail(item_uid("sword_dawn"))
	assert(game.panel.get_child(0) is EquipmentDetailScreen)
	await capture("equipment-legendary-detail")
	var gold: int = game.store.profile.gold
	button("Cường hóa +8").pressed.emit()
	assert(game.store.profile.gold == gold-160 and EquipmentSystem.item_for(game.store.profile, item_uid("sword_dawn")).enhance == 8)
	await capture("equipment-enhanced")
	game._item_detail(item_uid("accessory_7"))
	await capture("equipment-divine-detail")
	game._select_tab(1)
	game._inspect_character("eira")
	game._character_section(1)
	var screen: CharacterScreen = game.panel.get_child(0)
	for slot in EquipmentSystem.SLOTS: assert(screen.find_child("EquipmentSlot_"+slot, true, false) is Button)
	await capture("equipment-four-slots")
	game._character_item_detail(item_uid("spear_ember"), "ryn")
	var active: String = game.store.profile.hero
	button("Tháo về túi").pressed.emit()
	assert(game.store.profile.heroes.ryn.equipment.weapon == "" and game.store.profile.hero == active)
	button("Trang bị").pressed.emit()
	assert(game.store.profile.heroes.ryn.equipment.weapon == item_uid("spear_ember") and game.store.profile.hero == active)
	await capture("equipment-fire-set")
	assert(game.store.begin_run(1))
	game._item_detail(item_uid("sword_dawn"))
	assert(button("Cường hóa").disabled and button("Tháo về túi").disabled and button("Phân giải").disabled)
	await capture("equipment-pending-lock")
	# Render each rarity side by side for review without changing player data.
	var overlay := CanvasLayer.new()
	overlay.layer = 99
	root.add_child(overlay)
	var background := ColorRect.new()
	background.color = Color("0d1d2a")
	background.size = Vector2(540,960)
	overlay.add_child(background)
	var heading := Label.new()
	heading.text = "KHUNG TRANG BỊ · FIRST LIGHT"
	heading.position = Vector2(20,24)
	heading.add_theme_font_size_override("font_size",24)
	overlay.add_child(heading)
	for i in range(5):
		var holder := Control.new()
		holder.position = Vector2(12+(i%2)*264,90+(i/2)*270)
		overlay.add_child(holder)
		EquipmentArt.add_to(holder,game,"boots_%d" % (i+3),i+3,248)
		var caption := Label.new()
		caption.text = Recruitment.RARITIES[i+3].name
		caption.position = Vector2(0,240)
		caption.size.x = 248
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		holder.add_child(caption)
	await capture("equipment-five-frames")
	assert(EquipmentArt.frames.size() == 6)
	for frame in EquipmentArt.frames.values():
		assert(frame.filter_clip and frame.region.end.x <= frame.atlas.get_width() and frame.region.end.y <= frame.atlas.get_height())
	overlay.queue_free()
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.3).timeout
	game.queue_free()
	await process_frame
	print("PASS: five decorative frames, four slot filters/grid, detail real costs/upgrade, two active sets, inspected hero target and pending action lock rendered")
	quit()
