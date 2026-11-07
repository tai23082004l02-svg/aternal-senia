extends SceneTree

func _initialize() -> void:
	var library := FrameLibrary.new()
	var poses := 0
	for hero in ["eira", "ryn", "mira", "lyra"]:
		var unique := {}
		for clip in library.manifest.heroes[hero].values():
			for frame in clip.frames:
				assert(library.textures[frame.file] is AtlasTexture)
				var texture: AtlasTexture = library.textures[frame.file]
				assert(texture.region.end.x <= texture.atlas.get_width() and texture.region.end.y <= texture.atlas.get_height())
				assert(frame.hand[0] < frame.size[0] and frame.hand[1] < frame.size[1])
				unique[frame.file] = true
		assert(unique.size() == (32 if hero == "eira" else 16))
		poses += unique.size()
	for type in ["sword", "spear", "staff"]:
		for rank in [1, 2]:
			var texture: Texture2D = library.textures["%s_%d.svg" % [type, rank]]
			assert(texture is AtlasTexture or texture.resource_path.ends_with(".png"))
	for zone in ["forest", "ruins", "lake", "mountain", "tower"]:
		var texture: Texture2D = library.textures["bg_" + zone]
		assert(texture is AtlasTexture or texture.resource_path.ends_with(".png"))
	for enemy in ["slime", "wolf", "golem", "guardian", "mirror", "bird", "sentinel"]:
		assert(library.textures["enemy_" + enemy] is AtlasTexture)
	for type in ["guardian", "mirror", "bird", "sentinel"]:
		for state in ["idle", "charge", "slam"]:
			assert(library.enemy_frame(type, state, .2).has("atlas"))
	for name in library.painted.icons.regions:
		var texture: AtlasTexture = library.textures["icon_" + name]
		assert(texture.region.end.x <= texture.atlas.get_width() and texture.region.end.y <= texture.atlas.get_height())
	assert(library.companion_texture("ash", .3).resource_path.ends_with(".png"))
	assert(library.companion_texture("lumi", .3).resource_path.ends_with(".png"))
	print("PASS: %d painted hero poses, six weapons, five backgrounds, seven enemy roles, companions, clips and %d icons" % [poses, library.painted.icons.regions.size()])
	quit()
