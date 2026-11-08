extends SceneTree
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var audio := AudioDirector.new()
	root.add_child(audio)
	audio.configure(true,0,.0,0,.8)
	assert(audio.play("confirm"))
	assert(audio.players.any(func(p): return p.bus == AudioDirector.UI_BUS and p.playing))
	assert(not audio.play("cast"))
	audio.configure(true,.8,0,0,0)
	assert(not audio.players.any(func(p): return p.bus == AudioDirector.UI_BUS and p.playing))
	assert(not audio.play("confirm"))
	assert(audio.play("cast",true))
	assert(audio.players.any(func(p): return p.bus == AudioDirector.SFX_BUS and p.playing))
	audio.configure(false,.8,.35,.35,.8)
	assert(not audio.players.any(func(p): return p.playing))
	assert(audio.players.size() == 12)
	audio.shutdown()
	audio.queue_free()
	await process_frame
	await create_timer(.3).timeout
	print("PASS: independent UI/SFX mute and routing, bounded pool, master stops both")
	quit()
