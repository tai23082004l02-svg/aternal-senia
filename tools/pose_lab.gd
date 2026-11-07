extends Node2D

var library: FrameLibrary
var state := "idle"
var elapsed := 0.0
var playing := true
var speed := 1.0
var show_anchors := false
var weapon := "sword_1"
var readout: Label
var seek: HSlider
var play_button: Button

func _ready() -> void:
	library = FrameLibrary.new()
	var title := Label.new()
	title.text = "EIRA / POSE LAB"
	title.position = Vector2(24, 22)
	title.add_theme_font_size_override("font_size", 28)
	add_child(title)
	readout = Label.new()
	readout.position = Vector2(24, 65)
	add_child(readout)
	for i in range(6):
		var id: String = ["idle", "run", "attack", "skill", "hurt", "death"][i]
		_button(id, Vector2(24 + (i % 3) * 166, 650 + int(i / 3.0) * 48), Vector2(158, 40), _select.bind(id))
	play_button = _button("Dừng", Vector2(24, 762), Vector2(150, 42), _play)
	_button("← Frame", Vector2(190, 762), Vector2(150, 42), _step.bind(-1))
	_button("Frame →", Vector2(356, 762), Vector2(160, 42), _step.bind(1))
	seek = HSlider.new()
	seek.position = Vector2(24, 830)
	seek.size = Vector2(492, 30)
	seek.min_value = 0
	seek.step = .001
	seek.value_changed.connect(_seek)
	add_child(seek)
	var speeds := OptionButton.new()
	speeds.position = Vector2(24, 888)
	speeds.size = Vector2(150, 38)
	for value in [.25, .5, 1, 2, 3]:
		speeds.add_item("×%s" % value)
	speeds.select(2)
	speeds.item_selected.connect(_speed)
	add_child(speeds)
	var weapons := OptionButton.new()
	weapons.position = Vector2(190, 888)
	weapons.size = Vector2(150, 38)
	weapons.add_item("Kiếm sương")
	weapons.add_item("Nhật quang")
	weapons.item_selected.connect(_weapon)
	add_child(weapons)
	_button("Điểm neo", Vector2(356, 888), Vector2(160, 38), _anchors)

func _button(text: String, pos: Vector2, dimensions: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = dimensions
	button.pressed.connect(callback)
	add_child(button)
	return button

func _process(delta: float) -> void:
	if library == null:
		return
	var clip: Dictionary = library.manifest.heroes.eira[state]
	var total := _duration()
	if playing:
		elapsed += delta * speed
		if clip.loop:
			elapsed = fmod(elapsed, total)
		else:
			if elapsed >= total:
				playing = false
			elapsed = minf(elapsed, total - .00001)
	seek.set_block_signals(true)
	seek.max_value = total
	seek.set_value_no_signal(elapsed)
	seek.set_block_signals(false)
	play_button.text = "Dừng" if playing else "Phát"
	readout.text = "%s · frame %d / %d · %.3f / %.3f giây" % [state, _index() + 1, clip.frames.size(), elapsed, total]
	queue_redraw()

func _draw() -> void:
	if library == null:
		return
	draw_texture_rect(library.textures.bg_forest, Rect2(0, 155, 540, 454), false)
	var foot := Vector2(258, 570)
	var frame := library.frame_at("eira", state, elapsed)
	library.draw_actor(self, frame, foot, weapon, Color.WHITE, state != "death", 1.05)
	if show_anchors:
		var anchor := Vector2(frame.anchor[0], frame.anchor[1])
		var hand := foot + (Vector2(frame.hand[0], frame.hand[1]) - anchor) * 1.05
		draw_line(Vector2(0, foot.y), Vector2(540, foot.y), Color("d6b97d"), 1)
		draw_circle(foot, 4, Color("f6d18b"))
		draw_circle(hand, 4, Color("8de3d0"))

func _duration() -> float:
	var total := 0.0
	for frame in library.manifest.heroes.eira[state].frames:
		total += frame.duration
	return total

func _index() -> int:
	var cursor := elapsed
	var frames: Array = library.manifest.heroes.eira[state].frames
	for i in range(frames.size()):
		if cursor < frames[i].duration:
			return i
		cursor -= frames[i].duration
	return frames.size() - 1

func _select(id: String) -> void:
	state = id
	elapsed = 0
	playing = true

func _play() -> void:
	if elapsed >= _duration() - .001:
		elapsed = 0
	playing = not playing

func _step(direction: int) -> void:
	var frames: Array = library.manifest.heroes.eira[state].frames
	var target := posmod(_index() + direction, frames.size())
	elapsed = .00001
	for i in range(target):
		elapsed += frames[i].duration
	playing = false

func _seek(value: float) -> void:
	elapsed = minf(value, _duration() - .00001)
	playing = false

func _speed(index: int) -> void:
	speed = [.25, .5, 1, 2, 3][index]

func _weapon(index: int) -> void:
	weapon = "sword_%d" % (index + 1)

func _anchors() -> void:
	show_anchors = not show_anchors
