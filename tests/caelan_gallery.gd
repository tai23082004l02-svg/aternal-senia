extends SceneTree
class PoseBoard extends Control:
	var library: FrameLibrary
	var poses: Array = []
	func _draw() -> void:
		draw_rect(Rect2(0,0,540,960),Color("0b202c"))
		var font := UIFonts.font("display")
		draw_string(font,Vector2(20,32),"CAELAN · BATTLE ACTION PACK",HORIZONTAL_ALIGNMENT_LEFT,-1,20,Color("e9c782"))
		for i in range(poses.size()):
			var left: float = (i%4)*135
			var top: float = 60+(i/4)*210
			draw_style_box(StyleBoxEmpty.new(),Rect2(left,top,135,200))
			draw_line(Vector2(left+5,top+158),Vector2(left+130,top+158),Color("355259"))
			library.draw_actor(self,poses[i],Vector2(left+70,top+158),"sword_1",Color.WHITE,i<14,.4)
			draw_string(font,Vector2(left+10,top+185),"Pose %02d" % i,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("d9c7a0"))
func _initialize() -> void: call_deferred("run")
func run() -> void:
	root.size = Vector2i(540,960)
	var board := PoseBoard.new()
	board.library = FrameLibrary.new()
	var by_index := {}
	for clip in board.library.manifest.heroes.caelan.values():
		for frame in clip.frames: by_index[int(str(frame.file).get_slice("_",1))] = frame
	for i in range(16): board.poses.append(by_index[i])
	root.add_child(board)
	await process_frame
	await RenderingServer.frame_post_draw
	var dir := OS.get_environment("FIRST_LIGHT_CAPTURE_DIR")
	DirAccess.make_dir_recursive_absolute(dir)
	assert(root.get_texture().get_image().save_png(dir.path_join("caelan-16-poses.png")) == OK)
	print("PASS: sixteen Caelan poses rendered with sword sockets and death weapon visibility")
	quit()
