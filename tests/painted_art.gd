extends SceneTree

var library: FrameLibrary

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	library = FrameLibrary.new()
	var count := 0
	var unique: Array = []
	for state in library.manifest.heroes.eira:
		var total := 0.0
		for frame in library.manifest.heroes.eira[state].frames:
			var texture = library.textures[frame.file]
			assert(texture is AtlasTexture)
			assert(texture.filter_clip)
			assert(texture.region.end.x <= texture.atlas.get_width() and texture.region.end.y <= texture.atlas.get_height())
			assert(frame.hand[0] >= 0 and frame.hand[0] < frame.size[0])
			assert(frame.hand[1] >= 0 and frame.hand[1] < frame.size[1])
			assert(frame.anchor[1] <= frame.size[1])
			assert(library.frame_at("eira", state, total + .00001).file == frame.file)
			total += frame.duration
			count += 1
			if frame.file not in unique:
				unique.append(frame.file)
	assert(unique.size() == 32)
	for key in library.enemy_specs:
		var texture: AtlasTexture = library.textures["enemy_" + key]
		assert(texture.region.end.x <= texture.atlas.get_width() and texture.region.end.y <= texture.atlas.get_height())
	var lab = load("res://tools/pose_lab.tscn").instantiate()
	root.add_child(lab)
	await process_frame
	lab._select("attack")
	lab._step(1)
	assert(not lab.playing and lab._index() == 1)
	lab._step(-1)
	assert(lab._index() == 0)
	lab._seek(.23)
	assert(library.frame_at("eira", "attack", lab.elapsed).file == "painted/eira_08")
	lab._weapon(1)
	assert(lab.weapon == "sword_2")
	lab._speed(4)
	assert(lab.speed == 3)
	lab._select("death")
	lab._seek(10)
	assert(lab._index() == 1)
	lab.queue_free()
	await process_frame
	print("PASS: %d timed entries, 32 source poses, clipped atlas regions, sockets, seek/step, weapon and speed controls" % count)
	quit()
