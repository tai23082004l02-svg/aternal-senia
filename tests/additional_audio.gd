extends SceneTree

var game

func _initialize() -> void:
	OS.set_environment("FIRST_LIGHT_SAVE_DIR",ProjectSettings.globalize_path("user://first_light_tests/audio_v2_%d" % Time.get_ticks_usec()))
	call_deferred("run")

func reset_audio() -> void:
	for player in game.audio.players: player.stop()
	game.audio.last_played.clear()

func played(cue: String) -> int:
	return game.audio.slots.filter(func(slot): return slot.cue == cue).size()

func run() -> void:
	game = load("res://game/main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game._close_modal()
	var p: Dictionary = game.store.profile.duplicate(true)
	p.gold = 10000
	p.shards = 100
	p.cleared = [1,2]
	MissionBoard.record(p,"offline",1)
	assert(game.store.commit(p))
	reset_audio()
	game._on_button(game._bag_open.bind("equipment"))
	assert(played("menu_open") == 1 and game.tab == 2)
	reset_audio()
	game._dialog("Test","Close",[{"text":"Close","call":game._close_modal}])
	game._on_button(game._close_modal)
	assert(played("menu_back") == 1 and game.modal == null)
	reset_audio()
	game.store.fail_writes = true
	game._mission_claim("daily","offline")
	assert(played("quest_claim") == 0, "No success sound before reward commit")
	game.store.fail_writes = false
	game._mission_claim("daily","offline")
	assert(played("quest_claim") == 1)
	reset_audio()
	game._assist("ash")
	assert(played("spirit_select") == 1 and game.store.profile.assist == "ash")
	assert(game.store.forge("sword_1",3))
	var uid: String = game.store.profile.items[-3].uid
	reset_audio()
	game.store.fail_writes = true
	game._forge_fuse_execute(uid,game.store.fusion_donors(uid))
	assert(played("equipment_fuse") == 0)
	game.store.fail_writes = false
	game._forge_fuse_execute(uid,game.store.fusion_donors(uid))
	assert(played("equipment_fuse") == 1)
	reset_audio()
	game._bag_dismantle_execute([uid])
	assert(played("dismantle") == 1)
	reset_audio()
	game._summon_sound([{"kind":"item","id":"sword_1"}])
	assert(played("summon_reveal") == 1)
	reset_audio()
	game._summon_sound([{"kind":"hero","id":"eira"},{"kind":"item","id":"sword_1"}])
	assert(played("rarity_reveal") == 1 and played("summon_reveal") == 0, "One reveal for rare batch")
	reset_audio()
	var before: int = game.audio.played
	game._summon_history()
	game._close_modal()
	assert(game.audio.played == before, "History does not replay generated reward sound")
	game.audio.configure(false,.8,.35)
	assert(not game.audio.play("rarity_reveal"))
	game.audio.shutdown()
	for player in game.audio_players:
		player.stop()
		player.stream = null
	await create_timer(.2).timeout
	game.queue_free()
	await process_frame
	print("PASS:8 added cues, navigation, committed-only quest/fusion/dismantle/spirit sound, one summon reveal, silent history and mute")
	quit()
