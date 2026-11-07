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

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if interactive else Control.CURSOR_ARROW
	set_process(interactive)

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
	motion = (grab_origin + (position - pointer_origin) * .12).limit_length(11)
	queue_redraw()

func end_touch() -> void:
	if not dragging: return
	dragging = false
	pointer = -2
	velocity = Vector2(0, -30) if motion.length() < 1 else -motion * 4
	queue_redraw()

func advance_motion(delta: float) -> void:
	var remaining := clampf(delta, 0, .1)
	while remaining > 0:
		var dt := minf(remaining, 1.0 / 120)
		if not dragging:
			velocity += (-motion * 140 - velocity * 13) * dt
			motion = (motion + velocity * dt).limit_length(14)
		remaining -= dt
	idle_time += clampf(delta, 0, .1)
	touch_glow = maxf(0, touch_glow - delta * 1.8)
	if not dragging and motion.length() < .005 and velocity.length() < .02:
		motion = Vector2.ZERO
		velocity = Vector2.ZERO

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	if dragging and pointer == -1 and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): end_touch()
	advance_motion(delta)
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_VISIBILITY_CHANGED:
		dragging = false
		pointer = -2

func _draw() -> void:
	if library == null:
		return
	var foot := Vector2(size.x / 2, 185)
	draw_circle(foot - Vector2(0, 83), 79, Color("152936"))
	draw_arc(foot - Vector2(0, 83), 79, -.7, 4.4, 64, Color("655d4b"), 1)
	if interactive:
		if touch_glow > 0:
			draw_arc(foot - Vector2(0, 83), 83 + (1 - touch_glow) * 8, 0, TAU, 64, Color(.8, .9, 1, touch_glow * .3), 2, true)
		var breath := sin(idle_time * 2.1) * .006
		var stretch := clampf(-motion.y * .001, -.012, .012)
		var actor_scale := (.56 if hero == "eira" else .76) * (1 + breath + stretch)
		library.draw_actor(self, library.frame_at(hero, "idle", idle_time), foot + motion, weapon, palette_tint, true, actor_scale)
	else:
		library.draw_actor(self, library.frame_at(hero, "idle", 0), foot, weapon, palette_tint, true, .56 if hero == "eira" else .76)
