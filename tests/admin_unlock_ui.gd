extends SceneTree
var game
func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/admin_ui_%d" % Time.get_ticks_usec()))
	call_deferred("run")
func capture(name: String) -> void:
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	if dir.is_empty(): return
	DirAccess.make_dir_recursive_absolute(dir)
	assert(root.get_texture().get_image().save_png(dir.path_join(name+".png")) == OK)
func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.set_physics_process(false)
	game._close_modal()
	var before: Dictionary = game.store.profile.duplicate(true)
	game.tabs[4].pressed.emit()
	game.panel.get_child(0).entries.giftcode.pressed.emit()
	var input: LineEdit = game.modal.find_child("GiftCodeInput",true,false)
	assert(input.editable)
	input.text = "unknown"
	game.modal.find_child("RedeemGiftCode",true,false).pressed.emit()
	assert(game.store.profile == before and game.modal.has_node(input.get_path()))
	input.text = "admin"
	await capture("admin-code-entry")
	game.modal.find_child("RedeemGiftCode",true,false).pressed.emit()
	assert(game.store.profile == before)
	await capture("admin-confirm")
	game._utility_giftcode() # Dismiss confirmation without applying it.
	assert(game.store.profile == before)
	game._giftcode_confirm("admin")
	game._redeem_gift_code("admin")
	assert(game.modal == null and game.store.profile.redeemed_codes == ["admin"])
	var granted: Dictionary = game.store.profile.duplicate(true)
	game._utility_giftcode()
	game._giftcode_confirm("admin")
	assert(game.store.profile == granted)
	game._close_modal()
	game.store.read_only = true
	game._utility_giftcode()
	assert(not game.modal.find_child("GiftCodeInput",true,false).editable)
	assert(game.modal.find_child("RedeemGiftCode",true,false).disabled)
	game._close_modal()
	game.store.read_only = false
	game._select_tab(0)
	game.selected_stage = 1
	game._begin()
	game._utility_giftcode()
	assert(game.modal.find_child("RedeemGiftCode",true,false).disabled)
	game.audio.shutdown()
	game.queue_free()
	await process_frame
	print("PASS: editable code entry, unknown code, confirmation/cancel, grant/repeat, read-only and pending guards")
	quit()
