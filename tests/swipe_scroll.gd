extends SceneTree

var game
var clicks := 0

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/swipe_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func settle() -> void:
	for i in range(4): await process_frame

func pointer(position: Vector2, pressed: bool, touch: bool) -> void:
	if touch:
		var event := InputEventScreenTouch.new()
		event.index = 0
		event.position = position
		event.pressed = pressed
		Input.parse_input_event(event)
	else:
		var event := InputEventMouseButton.new()
		event.position = position
		event.global_position = position
		event.button_index = MOUSE_BUTTON_LEFT
		event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		event.pressed = pressed
		Input.parse_input_event(event)
	await process_frame

func swipe(position: Vector2, delta: Vector2, touch: bool) -> void:
	await pointer(position,true,touch)
	for i in range(1,9):
		var next := position+delta*float(i)/8
		if touch:
			var event := InputEventScreenDrag.new()
			event.index = 0
			event.position = next
			event.relative = delta/8
			Input.parse_input_event(event)
		else:
			var event := InputEventMouseMotion.new()
			event.position = next
			event.global_position = next
			event.relative = delta/8
			event.button_mask = MOUSE_BUTTON_MASK_LEFT
			Input.parse_input_event(event)
		await process_frame
	await pointer(position+delta,false,touch)
	await settle()

func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await settle()
	game._close_modal()
	game._select_tab(3)
	await settle()
	var original: Dictionary = game.store.profile.duplicate(true)
	assert(DisplayServer.is_touchscreen_available(), "Mouse emulation enables native content dragging in desktop/embedded player")
	var screen: MissionScreen = game.panel.get_child(0)
	var start: Vector2 = screen.claim_buttons.offline.get_global_rect().get_center()
	assert(game.scroll.get_global_rect().has_point(start))
	await swipe(start,Vector2(0,-110),false)
	print("mission mouse scroll=",game.scroll.scroll_vertical)
	assert(game.scroll.scroll_vertical > 30 and game.tab == 3 and game.store.profile == original, "Swipe over action must scroll without navigating or claiming")
	game._select_tab(3)
	await settle()
	screen = game.panel.get_child(0)
	start = screen.claim_buttons.offline.get_global_rect().get_center()
	await swipe(start,Vector2(0,-100),true)
	print("mission touch scroll=",game.scroll.scroll_vertical)
	assert(game.scroll.scroll_vertical > 30 and game.tab == 3 and game.store.profile == original)
	# Real nested inventory scroller must consume the drag without moving outer UI.
	var p: Dictionary = original.duplicate(true)
	for row in game.catalog.data.items: assert(game.store._add_item(p,row.id))
	assert(game.store.commit(p))
	original = game.store.profile.duplicate(true)
	game._bag_open("equipment")
	await settle()
	var inner := game.panel.find_child("BagContentScroll",true,false) as ScrollContainer
	assert(inner != null)
	var outer_before: int = game.scroll.scroll_vertical
	start = inner.get_global_rect().position+Vector2(80,170)
	await swipe(start,Vector2(0,-130),true)
	assert(inner.scroll_vertical > 40 and game.scroll.scroll_vertical == outer_before and game.tab == 2 and game.store.profile == original)
	game._select_tab(20)
	await settle()
	var shop: ShopScreen = game.panel.get_child(0)
	var strip := shop.get_child(0) as ScrollContainer
	start = strip.get_global_rect().position+Vector2(320,45)
	await swipe(start,Vector2(-150,0),true)
	assert(strip.scroll_horizontal > 50 and game.shop_page == 0 and game.store.profile == original, "Horizontal shop swipe must not choose a tab")
	# A plain tap still clicks once; a gesture staying inside a large button
	# must cancel its press rather than firing on release.
	var overlay := Control.new()
	root.add_child(overlay)
	var scroller := SwipeScroll.new()
	scroller.position = Vector2(30,230)
	scroller.size = Vector2(470,450)
	overlay.add_child(scroller)
	var box := VBoxContainer.new()
	scroller.add_child(box)
	var button := Button.new()
	button.text = "Gesture target"
	button.custom_minimum_size = Vector2(440,900)
	button.pressed.connect(func(): clicks += 1)
	box.add_child(button)
	await settle()
	start = Vector2(150,550)
	await pointer(start,true,true)
	await pointer(start,false,true)
	assert(clicks == 1)
	await swipe(start,Vector2(0,-90),true)
	assert(clicks == 1 and scroller.scroll_vertical > 30, "Native SCROLL_BEGIN cancels a click even if release remains inside the button")
	overlay.queue_free()
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS: native mouse/touch content swipes, mission action cancellation, nested inventory ownership, horizontal shop swipe, tap once and large-button drag cancellation")
	quit()
