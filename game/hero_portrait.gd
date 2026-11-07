class_name HeroPortrait
extends Control

var library: FrameLibrary
var hero := "eira"
var weapon := "sword_1"
var interactive := false
var palette_tint := Color.WHITE
var motion := Vector2.ZERO
var velocity := Vector2.ZERO
var dragging := false
var pointer := -2
var pointer_origin := Vector2.ZERO
var grab_origin := Vector2.ZERO
var idle_time := 0.0
var touch_glow := 0.0
var accessory_motion := Vector2.ZERO
var cloth_motion := Vector2.ZERO
var accessory_layers: Array[MeshInstance2D] = []

func _ready() -> void:
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if interactive else Control.CURSOR_ARROW
	set_process(interactive)
	_build_accessories()

func _gui_input(event: InputEvent) -> void:
	if not interactive: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed: begin_touch(event.position, -1)
		elif pointer == -1: end_touch()
		accept_event()
	elif event is InputEventMouseMotion and dragging and pointer == -1:
		move_touch(event.position)
		accept_event()
	elif event is InputEventScreenTouch:
		if event.pressed and not dragging: begin_touch(event.position, event.index)
		elif not event.pressed and event.index == pointer: end_touch()
		accept_event()
	elif event is InputEventScreenDrag and dragging and event.index == pointer:
		move_touch(event.position)
		accept_event()

func begin_touch(position: Vector2, id: int) -> void:
	if dragging: return
	dragging = true
	pointer = id
	pointer_origin = position
	grab_origin = motion
	velocity = Vector2.ZERO
	touch_glow = 1
	queue_redraw()

func move_touch(position: Vector2) -> void:
	if not dragging: return
	motion = (grab_origin + (position - pointer_origin) * (.2 if hero == "ryn" else .12)).limit_length(22 if hero == "ryn" else 11)
	queue_redraw()

func end_touch() -> void:
	if not dragging: return
	dragging = false
	pointer = -2
	velocity = Vector2(0, -105 if hero == "ryn" else -30) if motion.length() < 1 else -motion * (5.5 if hero == "ryn" else 4)
	queue_redraw()

func advance_motion(delta: float) -> void:
	var remaining := clampf(delta, 0, .1)
	while remaining > 0:
		var dt := minf(remaining, 1.0 / 120)
		if not dragging:
			velocity += (-motion * (115 if hero == "ryn" else 140) - velocity * (8 if hero == "ryn" else 13)) * dt
			motion = (motion + velocity * dt).limit_length(28 if hero == "ryn" else 14)
		accessory_motion = accessory_motion.lerp(motion, 1 - exp(-9 * dt))
		cloth_motion = cloth_motion.lerp(motion, 1 - exp(-5 * dt))
		remaining -= dt
	idle_time += clampf(delta, 0, .1)
	touch_glow = maxf(0, touch_glow - delta * 1.8)
	if not dragging and motion.length() < .005 and velocity.length() < .02:
		motion = Vector2.ZERO
		velocity = Vector2.ZERO
		if accessory_motion.length() < .01: accessory_motion = Vector2.ZERO

	_sync_accessories()

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	if dragging and pointer == -1 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): end_touch()
	advance_motion(delta)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED: _sync_accessories()
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_VISIBILITY_CHANGED:
		dragging = false
		pointer = -2

func _draw() -> void:
	if library == null:
		return
	if library.textures.has("portrait_" + hero):
		var texture: Texture2D = library.textures["portrait_" + hero]
		var factor := minf((size.x - 36) / texture.get_width(), (size.y - 80) / texture.get_height())
		var breath := sin(idle_time * 2.1) * .008 if interactive else 0.0
		var scale := Vector2.ONE * factor * (1 + breath)
		var center := size * .5 + (motion if interactive else Vector2.ZERO)
		if library.textures.has("portrait_" + hero + "_body"):
			var angle := motion.x * .003 if interactive else 0.0
			var lag := (accessory_motion - motion) * .18 if interactive else Vector2.ZERO
			var sway := clampf(lag.x * .01, -.025, .025) + sin(idle_time * 1.6) * .004 if interactive else 0.0
			if accessory_layers.is_empty() and library.textures.has("portrait_" + hero + "_back"):
				draw_set_transform(center + lag, angle + sway, scale)
				draw_texture(library.textures["portrait_" + hero + "_back"], -texture.get_size() * .5, palette_tint)
			draw_set_transform(center, angle, scale)
			draw_texture(library.textures["portrait_" + hero + "_body"], -texture.get_size() * .5, palette_tint)
		else:
			draw_set_transform(center, motion.x * .003 if interactive else 0.0, scale)
			draw_texture(texture, -texture.get_size() * .5, palette_tint)
		draw_set_transform(Vector2.ZERO)
		if interactive and touch_glow > 0:
			draw_arc(size * .5, minf(size.x, size.y) * .4, 0, TAU, 64, Color(1, .68, .35, touch_glow * .3), 2, true)
		return
	var foot := Vector2(size.x / 2, 185)
	draw_circle(foot - Vector2(0, 83), 79, Color("152936"))
	draw_arc(foot - Vector2(0, 83), 79, -.7, 4.4, 64, Color("655d4b"), 1)
	if interactive:
		if touch_glow > 0:
			draw_arc(foot - Vector2(0, 83), 83 + (1 - touch_glow) * 8, 0, TAU, 64, Color(.8, .9, 1, touch_glow * .3), 2, true)
		var breath := sin(idle_time * 2.1) * .006
		var stretch := clampf(-motion.y * .001, -.012, .012)
		var actor_scale := (.56 if hero in ["eira", "mira", "lyra"] else .76) * (1 + breath + stretch)
		library.draw_actor(self, library.frame_at(hero, "idle", idle_time), foot + motion, weapon, palette_tint, true, actor_scale)
	else:
		library.draw_actor(self, library.frame_at(hero, "idle", 0), foot, weapon, palette_tint, true, .56 if hero in ["eira", "mira", "lyra"] else .76)

# Cached grid: attachment rows stay fixed; only the free ends bend.
# No skeleton, external runtime, or simulation state is involved.
func _build_accessories() -> void:
	if library == null or hero != "ryn": return
	for part in ["cloth", "hair"]:
		if not library.textures.has("portrait_ryn_" + part): return
	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	for y in range(17):
		for x in range(9):
			var uv := Vector2(x / 8.0, y / 16.0)
			vertices.append((uv - Vector2(.5, .5)) * Vector2(1024, 1536))
			uvs.append(uv)
	for y in range(16):
		for x in range(8):
			var a := y * 9 + x
			indices.append_array(PackedInt32Array([a, a + 1, a + 9, a + 1, a + 10, a + 9]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	for part in ["cloth", "hair"]:
		var layer := MeshInstance2D.new()
		layer.mesh = mesh
		layer.texture = library.textures["portrait_ryn_" + part]
		layer.show_behind_parent = true
		var shader := ShaderMaterial.new()
		shader.shader = preload("res://game/shaders/portrait_sway.gdshader")
		shader.set_shader_parameter("root_y", .31 if part == "cloth" else .13)
		shader.set_shader_parameter("span", .55 if part == "cloth" else .18)
		layer.material = shader
		add_child(layer)
		accessory_layers.append(layer)
	_sync_accessories()

func _sync_accessories() -> void:
	if accessory_layers.is_empty(): return
	var factor := maxf(.001, minf((size.x - 36) / 1024, (size.y - 80) / 1536))
	var breath := sin(idle_time * 2.1) * .008 if interactive else 0.0
	for i in range(accessory_layers.size()):
		var layer := accessory_layers[i]
		layer.position = size * .5 + (motion if interactive else Vector2.ZERO)
		layer.scale = Vector2.ONE * factor * (1 + breath)
		layer.rotation = motion.x * .003 if interactive else 0.0
		layer.modulate = palette_tint
		var shader: ShaderMaterial = layer.material
		var lag := (cloth_motion.x if i == 0 else accessory_motion.x) - motion.x
		shader.set_shader_parameter("phase", idle_time * (1.8 if i == 0 else 2.5))
		shader.set_shader_parameter("lag", clampf(lag / factor * .35, -65, 65) if interactive else 0.0)
		shader.set_shader_parameter("amplitude", (12.0 if i == 0 else 8.0) if interactive else 0.0)
