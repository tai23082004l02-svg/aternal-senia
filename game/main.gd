extends Node2D

# Original mechanics and vector placeholders; no extracted game assets.
const SAVE_PATH = "user://first_light_v1.json"
var hp := 180.0
var enemy_hp := 60.0
var enemy_max := 60.0
var wave := 0
var gold := 0
var level := 1
var timer := 0.0
var auto_clock := 0.0
var enemy_clock := 0.0
var assist_clock := 0.0
var flash := 0.0
var cooldowns := [0.0, 0.0, 0.0]
var state := "ready"
var settled := false
var banner := "Khu rừng ánh trăng"
var hud: Label
var info: Label
var start_button: Button
var upgrade_button: Button
var skills: Array[Button] = []

func _ready() -> void:
	_load_progress()
	var title := Label.new()
	title.text = "FIRST LIGHT"
	title.position = Vector2(32, 40)
	title.add_theme_font_size_override("font_size", 36)
	add_child(title)
	var subtitle := Label.new()
	subtitle.text = "ATERNAL SENIA  /  BẢN MẪU 0.1"
	subtitle.position = Vector2(34, 88)
	subtitle.modulate = Color("9baacc")
	add_child(subtitle)
	hud = Label.new()
	hud.position = Vector2(32, 142)
	hud.add_theme_font_size_override("font_size", 20)
	add_child(hud)
	info = Label.new()
	info.position = Vector2(32, 645)
	info.size = Vector2(476, 100)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 20)
	add_child(info)
	for i in range(3):
		var b := _button(["Kiếm quang", "Hồi phục", "Tinh linh"][i], Vector2(32 + i * 162, 758), Vector2(152, 70))
		b.pressed.connect(_skill.bind(i))
		skills.append(b)
	start_button = _button("Bắt đầu hành trình", Vector2(32, 852), Vector2(292, 64))
	start_button.pressed.connect(_start)
	upgrade_button = _button("Nâng cấp · 30", Vector2(338, 852), Vector2(170, 64))
	upgrade_button.pressed.connect(_upgrade)
	_refresh()

func _button(caption: String, pos: Vector2, dimensions: Vector2) -> Button:
	var b := Button.new()
	b.text = caption
	b.position = pos
	b.size = dimensions
	b.add_theme_font_size_override("font_size", 18)
	add_child(b)
	return b

func _start() -> void:
	if state == "battle":
		return
	hp = 180.0 + (level - 1) * 25
	wave = 0
	settled = false
	cooldowns = [0.0, 0.0, 0.0]
	auto_clock = 0.0
	enemy_clock = 0.0
	assist_clock = 0.0
	state = "battle"
	_spawn()
	_refresh()

func _spawn() -> void:
	enemy_max = [60.0, 90.0, 260.0][wave]
	enemy_hp = enemy_max
	enemy_clock = 0.0
	banner = ["01 · Mầm bóng tối", "02 · Sói pha lê", "03 · Người giữ rừng"][wave]

func _physics_process(delta: float) -> void:
	timer += delta
	flash = maxf(0.0, flash - delta)
	if state == "battle":
		for i in range(3):
			cooldowns[i] = maxf(0.0, cooldowns[i] - delta)
		auto_clock += delta
		assist_clock += delta
		enemy_clock += delta
		if auto_clock >= 0.8:
			auto_clock -= 0.8
			_damage(10.0 + level * 2)
		if state == "battle" and assist_clock >= 2.0:
			assist_clock -= 2.0
			_damage(7.0 + level)
		if state == "battle" and enemy_clock >= 2.8:
			enemy_clock = 0.0
			hp = maxf(0.0, hp - (32.0 if wave == 2 else 12.0))
			if hp <= 0.0:
				state = "lost"
				banner = "Chưa vượt qua · Thử phối hợp kỹ năng"
	_refresh()
	queue_redraw()

func _damage(amount: float) -> void:
	if state != "battle":
		return
	enemy_hp = maxf(0.0, enemy_hp - amount)
	flash = 0.18
	if enemy_hp <= 0.0:
		if wave < 2:
			wave += 1
			_spawn()
		else:
			state = "won"
			banner = "Rừng đã yên bình · +40 vàng"
			if not settled:
				settled = true
				gold += 40
				_save_progress()

func _skill(index: int) -> void:
	if state != "battle" or cooldowns[index] > 0.0:
		return
	cooldowns[index] = [5.0, 9.0, 12.0][index]
	match index:
		0: _damage(38.0 + level * 4)
		1: hp = minf(180.0 + (level - 1) * 25, hp + 65.0)
		2: _damage(65.0 + level * 5)
	_refresh()

func _upgrade() -> void:
	if state == "battle" or gold < 30:
		return
	gold -= 30
	level += 1
	_save_progress()
	_refresh()

func _refresh() -> void:
	if hud == null:
		return
	hud.text = "KIẾM SĨ · CẤP %d                         %d VÀNG" % [level, gold]
	info.text = banner + "\n" + ("Tự đánh đang bật · Trợ chiến mỗi 2 giây" if state == "battle" else "Vượt 2 đợt quái và boss. Dùng vàng để mạnh hơn.")
	start_button.disabled = state == "battle"
	start_button.text = "Đang chiến đấu…" if state == "battle" else "Bắt đầu hành trình"
	upgrade_button.disabled = state == "battle" or gold < 30
	for i in range(3):
		skills[i].disabled = state != "battle" or cooldowns[i] > 0
		skills[i].text = ["Kiếm quang", "Hồi phục", "Tinh linh"][i] + (" · %ds" % ceili(cooldowns[i]) if cooldowns[i] > 0 else "")

func _draw() -> void:
	for i in range(8):
		draw_rect(Rect2(i * 78 - 20, 220, 26, 370), Color(0.08, 0.14, 0.20, 0.8))
	draw_circle(Vector2(420, 265), 44, Color("d4e9df"))
	draw_colored_polygon(PackedVector2Array([Vector2(0, 500), Vector2(140, 420), Vector2(300, 530), Vector2(450, 440), Vector2(540, 480), Vector2(540, 630), Vector2(0, 630)]), Color("132c39"))
	draw_rect(Rect2(0, 584, 540, 46), Color("223d43"))
	for i in range(22):
		var p := Vector2(fmod(i * 97.0 + timer * 9, 540), 300 + fmod(i * 43.0, 270))
		draw_circle(p, 2, Color(0.5, 0.9, 0.8, 0.5))
	var bob := sin(timer * 3) * 3
	var hero := Vector2(145, 550 + bob)
	draw_ellipse_shadow(Vector2(145, 584), 34)
	draw_colored_polygon(PackedVector2Array([hero + Vector2(-26, 20), hero + Vector2(-12, -55), hero + Vector2(16, -55), hero + Vector2(32, 20)]), Color("7a78cf"))
	draw_circle(hero + Vector2(0, -76), 20, Color("eacbbd"))
	draw_arc(hero + Vector2(0, -80), 23, PI, TAU, 18, Color("c9d8ec"), 12)
	draw_line(hero + Vector2(21, -28), hero + Vector2(55, -85 if flash > 0 else -45), Color("d9f8ff"), 7)
	draw_circle(Vector2(76, 453 + sin(timer * 2) * 10), 12, Color("80edd2"))
	var enemy := Vector2(390, 555)
	draw_ellipse_shadow(Vector2(390, 584), 40)
	var color := Color("edb17b") if wave == 2 else Color("9e7bb5")
	if flash > 0:
		color = Color.WHITE
	draw_circle(enemy + Vector2(0, -25), 48 if wave == 2 else 34, color)
	draw_circle(enemy + Vector2(-12, -32), 4, Color("28243d"))
	draw_circle(enemy + Vector2(12, -32), 4, Color("28243d"))
	if state == "battle" and enemy_clock > 2.0:
		draw_arc(enemy, 60, PI, TAU, 32, Color("ff805c"), 5)
	_bar(Vector2(64, 610), hp / (180.0 + (level - 1) * 25), Color("80e0be"), 175)
	_bar(Vector2(300, 610), enemy_hp / enemy_max, Color("df8899"), 175)
	if flash > 0:
		draw_arc(Vector2(270, 510), 90, -1.1, 1.1, 24, Color("c6fafa"), 8)

func draw_ellipse_shadow(center: Vector2, radius: float) -> void:
	draw_set_transform(center, 0, Vector2(1, 0.22))
	draw_circle(Vector2.ZERO, radius, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2.ZERO)

func _bar(pos: Vector2, fraction: float, color: Color, width: float) -> void:
	draw_rect(Rect2(pos, Vector2(width, 7)), Color("293044"))
	draw_rect(Rect2(pos, Vector2(width * clampf(fraction, 0, 1), 7)), color)

func _save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)
	if file == null:
		push_error("Không ghi được tiến trình")
		return
	file.store_string(JSON.stringify({"version": 1, "gold": gold, "level": level}))
	file.close()
	var result := DirAccess.rename_absolute(SAVE_PATH + ".tmp", SAVE_PATH)
	if result != OK:
		push_error("Không lưu được tiến trình: %s" % result)

func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if data is Dictionary and data.get("version") == 1:
		gold = maxi(0, int(data.get("gold", 0)))
		level = maxi(1, int(data.get("level", 1)))
