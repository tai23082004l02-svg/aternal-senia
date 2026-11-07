extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var frames := FrameLibrary.new()
	assert(frames.painted.portraits.ryn.adult_age == 27)
	assert(frames.textures.has("portrait_ryn"))
	assert(frames.textures.has("portrait_ryn_back") and frames.textures.has("portrait_ryn_body"))
	var seen := {}
	for state in ["idle", "run", "attack", "skill", "guard", "hurt", "death"]:
		var clip: Dictionary = frames.manifest.heroes.ryn[state]
		assert(not clip.frames.is_empty())
		for frame in clip.frames:
			seen[frame.file] = true
			var tex: AtlasTexture = frames.textures[frame.file]
			assert(tex.region.position.x >= 0 and tex.region.position.y >= 0)
			assert(tex.region.end.x <= tex.atlas.get_width() and tex.region.end.y <= tex.atlas.get_height())
			assert(frame.duration > 0 and frame.embedded_weapon)
			assert(Vector2(frame.source_size[0], frame.source_size[1]) == Vector2(512, 512))
			assert(Vector2(frame.source_anchor[0], frame.source_anchor[1]) - Vector2(frame.trim_offset[0], frame.trim_offset[1]) == Vector2(frame.anchor[0], frame.anchor[1]))
	assert(seen.size() == 12)
	var ryn := HeroPortrait.new()
	var eira := HeroPortrait.new()
	ryn.library = frames
	ryn.hero = "ryn"
	root.add_child(ryn)
	assert(ryn.accessory_layers.size() == 2)
	for layer in ryn.accessory_layers:
		assert(layer.texture.get_size() == Vector2(1024, 1536))
		assert(layer.show_behind_parent)
		assert(layer.material.get_shader_parameter("amplitude") == 0.0)
	ryn.interactive = true
	ryn.hero = "ryn"
	ryn.begin_touch(Vector2.ZERO, 0)
	ryn.move_touch(Vector2(1000, -1000))
	assert(ryn.motion.length() <= 22.01 and ryn.motion.length() > 14)
	ryn.end_touch()
	for i in range(360):
		ryn.advance_motion(1.0 / 60)
		assert(ryn.motion.length() <= 28.01)
	assert(ryn.motion == Vector2.ZERO)
	assert(ryn.accessory_motion.length() < .1)
	ryn.begin_touch(Vector2.ZERO, 0)
	eira.begin_touch(Vector2.ZERO, 0)
	ryn.end_touch()
	eira.end_touch()
	var ryn_peak := 0.0
	var eira_peak := 0.0
	for i in range(120):
		ryn.advance_motion(1.0 / 60)
		eira.advance_motion(1.0 / 60)
		ryn_peak = maxf(ryn_peak, ryn.motion.length())
		eira_peak = maxf(eira_peak, eira.motion.length())
	assert(ryn_peak > eira_peak * 2)
	ryn.free()
	eira.free()
	print("PASS: adult Ryn portrait, 12 bounded poses, embedded spear, stronger capped rebound and settle")
	quit()
