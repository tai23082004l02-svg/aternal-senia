extends SceneTree
var game
var output := "user://first_light_previews/dungeons"

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/dungeon_world_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func settle() -> void:
	for i in range(4): await process_frame

func screen() -> DungeonScreen:
	return game.panel.get_child(0) as DungeonScreen

func capture(name: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(output.path_join(name+".png")) == OK)

func mouse(position: Vector2, down: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if down else 0
	event.pressed = down
	Input.parse_input_event(event)
	await process_frame

func run() -> void:
	if not OS.get_environment("FIRST_LIGHT_CAPTURE_DIR").is_empty(): output = OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(output)
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await settle()
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 1234
	p.xp = 485
	p.shards = 52
	p.cleared = [1,2,3]
	assert(game.store.commit(p))
	var original: Dictionary = game.store.profile.duplicate(true)
	game._select_tab(21)
	await settle()
	var world := DungeonWorld.new()
	assert(world.entries.size()==15)
	for i in range(15):
		var art := DungeonWorld.artwork(i)
		assert(art.filter_clip and art.region.has_area() and art.region.end.x <= art.atlas.get_width() and art.region.end.y <= art.atlas.get_height())
	for i in range(12):
		var art := DungeonWorld.artwork(i,true)
		assert(art.filter_clip and art.region.has_area() and art.region.end.y <= art.atlas.get_height())
	assert(screen().cards.size()==15 and game.tabs[3].visible)
	await capture("dungeons-all")
	# Native drag starts on a card's action, scrolls, and does not open a dungeon.
	var open := screen().find_child("DungeonOpen_grove",true,false) as Button
	var point := open.get_global_rect().get_center()
	await mouse(point,true)
	for i in range(1,9):
		var event := InputEventMouseMotion.new()
		event.position = point+Vector2(0,-100.0*i/8)
		event.global_position = event.position
		event.relative = Vector2(0,-12.5)
		event.button_mask = MOUSE_BUTTON_MASK_LEFT
		Input.parse_input_event(event)
		await process_frame
	await mouse(point+Vector2(0,-100),false)
	await settle()
	assert(screen().list_scroll.scroll_vertical>30 and game.dungeon_selected.is_empty())
	for key in DungeonWorld.GROUPS:
		game._dungeon_filter(key)
		await settle()
		assert(screen().cards.size()=={"all":15,"resource":5,"tactic":5,"boss":4,"endless":1,"seasonal":0}[key])
		assert(game.store.profile==original)
		if key in ["resource","tactic","seasonal"]: await capture("dungeons-"+key)
	game._dungeon_filter("all")
	for row in world.entries:
		game._dungeon_show(row.id)
		await settle()
		assert(screen().challenge_button != null)
		assert(screen().challenge_button.disabled == (row.stage==0))
		var before_stage: int = game.selected_stage
		if row.stage==0:
			game._dungeon_enter(row.id)
			assert(game.selected_stage==before_stage and game.modal==null)
			game._dungeon_difficulty(2)
			await settle()
		if row.id in ["crystal_mine","dawn_wardens","endless_spire"]:
			await capture("dungeon-"+row.id)
			screen().list_scroll.scroll_vertical = 10000
			await capture("dungeon-"+row.id+"-bottom")
			assert(screen().challenge_button.get_global_rect().end.y <= game.tabs[3].global_position.y+2)
		assert(game.store.profile==original,"Browsing/previews must not mutate save")
		game._dungeon_back()
		await settle()
	for id in ["grove","six_waves","dawn_wardens"]:
		game._dungeon_show(id)
		await settle()
		game._dungeon_enter(id)
		assert(game.selected_stage==world.find(id).stage and game.modal != null and game.store.profile==original)
		game._close_modal()
	# Existing unlock condition, pending snapshot and battle continuation remain intact.
	p = game.store.profile.duplicate(true)
	p.cleared = []
	assert(game.store.commit(p))
	game._dungeon_show("grove")
	await settle()
	assert(screen().challenge_button.disabled)
	game._dungeon_enter("grove")
	assert(game.modal==null)
	assert(game.store.commit(original))
	game._dungeon_enter("grove")
	game._begin()
	assert(game.battle is TeamBattle and not game.store.profile.pending.is_empty())
	var pending: Dictionary = game.store.profile.duplicate(true)
	game._select_tab(21)
	game._dungeon_show("grove")
	await settle()
	assert(screen().challenge_button.disabled and game.battle.paused)
	game._dungeon_enter("grove")
	assert(game.store.profile==pending)
	game._select_tab(0)
	assert(not game.battle.paused)
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS:15 dungeons/4 groups/seasonal, reviewed art, native swipe, all previews without save writes, three original routes, unlock/pending locks and battle continuation")
	quit()
