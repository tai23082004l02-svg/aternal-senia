class_name TeamBattleUI
extends Control
var game
var field: TeamField
var heading: Label
var notice: Label
var names: Array[Label] = []
var hp_texts: Array[Label] = []
var health: Array[ProgressBar] = []
var energy: Array[ProgressBar] = []
var ultimates: Array[Button] = []
var auto_button: Button
var next_button: Button
var pause_button: Button
var speed_button: Button

func _ready() -> void:
	position = Vector2(0, 132)
	size = Vector2(540, 732)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	heading = game._label(self, "", Vector2(24, 6), 17, Color("e5cd9e"))
	field = TeamField.new()
	field.game = game
	field.position = Vector2(0, 46)
	field.size = Vector2(540, 330)
	add_child(field)
	for i in range(4):
		var box := Panel.new()
		box.position = Vector2(24 + i * 125, 391)
		box.size = Vector2(117, 117)
		box.add_theme_stylebox_override("panel", game._style(Color("152c37"), Color("8e7b53"), 10))
		add_child(box)
		names.append(game._label(box, "", Vector2(8, 5), 16, Color("e5cd9e")))
		var hp := ProgressBar.new()
		hp.position = Vector2(8, 40)
		hp.size = Vector2(101, 7)
		hp.show_percentage = false
		box.add_child(hp)
		health.append(hp)
		hp_texts.append(game._label(box, "", Vector2(8, 25), 10))
		_bar_style(hp, Color("8bd6b6"))
		var nrg := ProgressBar.new()
		nrg.position = Vector2(8, 54)
		nrg.size = Vector2(101, 7)
		nrg.show_percentage = false
		box.add_child(nrg)
		energy.append(nrg)
		_bar_style(nrg, Color("d4b56d"))
		var button: Button = game._button(box, "", Vector2(7, 65), Vector2(103, 42), _ultimate.bind(i))
		button.add_theme_font_size_override("font_size", 13)
		ultimates.append(button)
	auto_button = game._button(self, "", Vector2(24, 522), Vector2(148, 44), _auto)
	auto_button.add_theme_font_size_override("font_size", 14)
	speed_button = game._button(self, "×1", Vector2(180, 522), Vector2(64, 44), game._speed)
	pause_button = game._button(self, "Dừng", Vector2(252, 522), Vector2(96, 44), game._toggle_pause)
	next_button = game._button(self, "", Vector2(356, 522), Vector2(160, 44), _next)
	next_button.add_theme_font_size_override("font_size", 14)
	game._button(self, "Rút lui · Không nhận thưởng", Vector2(24, 581), Vector2(492, 46), game._confirm_abandon)
	game._button(self, "Đội hình & Nhân vật", Vector2(24, 640), Vector2(492, 46), game._select_tab.bind(22))
	notice = game._label(self, "", Vector2(24, 698), 12)
	notice.size = Vector2(492, 24)
	notice.clip_text = true

func _process(_delta: float) -> void:
	visible = game.tab == 0 and game.battle is TeamBattle
	if not visible: return
	var model: TeamBattle = game.battle
	field.model = model
	field.position = Vector2(0,46)
	if game.presentation_options.screen_shake and not game.presentation_options.battery_saver:
		for event in model.events:
			var age: float = model.time-event.time
			if event.kind == "hurt" and age >= 0 and age < .15:
				field.position += Vector2(sin(age*110+event.id),cos(age*133+event.id))*1.5*(1-age/.15)
	field.position = Vector2(0,46) + (field.position-Vector2(0,46)).limit_length(3.2)
	field.queue_redraw()
	var code := JourneyScreen.stage_code(game.catalog, model.stage)
	heading.text = "ẢI %s · %s · %02d:%02d · Đợt %d/%d" % [code, model.stage.name, int(model.time) / 60, int(model.time) % 60, model.wave + 1, model.wave_count()]
	heading.add_theme_font_size_override("font_size", 14)
	var can_play := model.state == "battle" and not model.paused and game.modal == null
	for i in range(4):
		if i < 3:
			if i >= model.allies.size():
				names[i].text = "Ô trống"
				hp_texts[i].text = "Chưa có tướng"
				health[i].value = 0
				energy[i].value = 0
				ultimates[i].text = "Chưa xếp"
				ultimates[i].disabled = true
				continue
			var ally: Dictionary = model.allies[i]
			names[i].text = game.catalog.find_row("heroes", ally.id).name
			hp_texts[i].text = "%d / %d HP" % [ally.hp, ally.stats.hp]
			health[i].value = ally.hp / ally.stats.hp * 100
			energy[i].value = ally.energy
			ultimates[i].text = "Đã hạ" if ally.hp <= 0 else "Nộ %d%%" % ally.energy
			ultimates[i].disabled = not can_play or ally.hp <= 0 or ally.energy < 100 or not ally.action.is_empty()
		else:
			names[i].text = game.catalog.find_row("assists", model.stats.assist).name
			hp_texts[i].text = "Hỗ trợ toàn đội"
			health[i].visible = false
			energy[i].value = model.spirit_energy
			ultimates[i].text = "Nộ %d%%" % model.spirit_energy
			ultimates[i].disabled = not can_play or model.spirit_energy < 100 or not model.spirit_action.is_empty()
	auto_button.text = "AUTO ULT: " + ("BẬT" if model.auto_ultimate else "TẮT")
	next_button.text = "Tự qua ải: " + ("Bật" if model.auto_next else "Tắt")
	speed_button.text = "×%d" % model.speed
	pause_button.text = "Tiếp tục" if model.paused else "Dừng"
	notice.text = model.warning() + " · Chạm quái để chọn mục tiêu"

func _bar_style(bar: ProgressBar, color: Color) -> void:
	var background := StyleBoxFlat.new()
	background.bg_color = Color("293e46")
	background.set_corner_radius_all(3)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	bar.size = Vector2(101, 7)

func _ultimate(index: int) -> void:
	if game.battle is TeamBattle and game.modal == null:
		if index == 3: game.battle.spirit_ultimate()
		else: game.battle.ultimate(index)
func _auto() -> void:
	if game.battle is TeamBattle: game.battle.auto_ultimate = not game.battle.auto_ultimate
func _next() -> void:
	if game.battle is TeamBattle: game.battle.auto_next = not game.battle.auto_next

class TeamField extends Control:
	var game
	var model: TeamBattle
	const ALLY_FEET := [Vector2(213, 273), Vector2(102, 200), Vector2(92, 310)]
	const ENEMY_FEET := [Vector2(348, 272), Vector2(439, 200), Vector2(456, 312), Vector2(346, 134)]
	func _ready() -> void:
		clip_contents = true
		mouse_filter = Control.MOUSE_FILTER_STOP
	func _gui_input(event: InputEvent) -> void:
		if model == null: return
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT or event is InputEventScreenTouch and event.pressed:
			var selected := -1
			var distance := 65.0
			for i in range(model.enemies.size()):
				if model.enemies[i].hp <= 0: continue
				var d: float = event.position.distance_to(ENEMY_FEET[i] - Vector2(0, 40))
				if d < distance:
					distance = d
					selected = i
			if selected >= 0: model.select_target(selected)
			accept_event()
	func _draw() -> void:
		if model == null: return
		var library: FrameLibrary = game.frames
		draw_texture_rect(library.textures["bg_" + model.stage.zone], Rect2(0, 0, 540, 330), false)
		var options: Dictionary = game.presentation_options
		if options.lighting and options.quality != "low" and not options.battery_saver: EnvironmentMotion.draw_motes(self, model.stage.zone, model.time, false)
		var font := ThemeDB.fallback_font
		draw_string(font, Vector2(20, 22), "ĐỘI MÌNH", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ecd095"))
		draw_string(font, Vector2(407, 22), "KẺ ĐỊCH", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ecd095"))
		var order := []
		for i in range(model.allies.size()): order.append({"enemy":false,"index":i,"y":ALLY_FEET[model.allies[i].slot].y})
		for i in range(model.enemies.size()): order.append({"enemy":true,"index":i,"y":ENEMY_FEET[i].y})
		order.sort_custom(func(a,b): return a.y < b.y)
		for row in order:
			if row.enemy: _enemy(row.index, library)
			else: _ally(row.index, library)
		var spirit := Vector2(177, 95) + Vector2(0, sin(model.time * 2) * 4)
		var flash := clampf(1 - (model.time - model.spirit_last) * 2, 0, 1)
		draw_texture_rect(library.textures["companion_" + model.stats.assist], Rect2(spirit - Vector2(26, 26), Vector2(52, 52)), false)
		if flash > 0 and options.lighting: draw_arc(spirit, 27 + flash * 10, 0, TAU, 24, Color(.6, 1, .8, flash), 2, true)
		for event in model.events:
			var age: float = model.time - event.time
			if age < 0 or age > .7 or event.wave != model.wave or event.target < 0: continue
			if event.kind not in ["hit","critical","hurt","heal","guard"]: continue
			var ally_target: bool = event.kind in ["hurt","heal","guard"]
			if ally_target and event.target >= model.allies.size() or not ally_target and event.target >= model.enemies.size(): continue
			if not ally_target and event.get("target_uid", -1) != model.enemies[event.target].id: continue
			var point: Vector2 = ALLY_FEET[model.allies[event.target].slot] if ally_target else ENEMY_FEET[event.target]
			var color := Color("87e6b5") if event.kind == "heal" else (Color("ffcb78") if event.kind == "critical" else Color("f5ddd2"))
			color.a = 1 - age / .7
			if options.damage_numbers: draw_string(font, point + Vector2(-10, -82 - age * 25), event.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, color)
			if age < .18 and options.quality != "low" and options.lighting and not options.reduced_effects and not options.battery_saver:
				CombatEffects.stamp(self, library, "heal_ring" if event.kind == "heal" else "impact", point - Vector2(0,35), Vector2.ONE * 65, 1 - age / .18)
				if options.quality == "high": draw_arc(point - Vector2(0, 35), 12 + age * 80, 0, TAU, 16, color, 2, true)
	func _ally(index: int, library: FrameLibrary) -> void:
		var ally: Dictionary = model.allies[index]
		var foot: Vector2 = ALLY_FEET[ally.slot]
		var state := "idle"
		var elapsed: float = model.time
		var marker := -1.0
		var duration := -1.0
		var last: Dictionary = ally.last
		if ally.hp <= 0:
			state = "death"
			elapsed = model.time - ally.hurt
		elif model.state != "battle":
			state = "idle"
		elif model.move_clock > 0:
			state = "run"
		elif not last.is_empty() and model.time - last.started < last.duration:
			elapsed = model.time - last.started
			state = "attack" if last.kind == "attack" else "skill"
			marker = last.marker
			duration = last.duration
			if last.kind != "heal": foot.x += CombatPresentation.lunge(elapsed, marker, duration) * .25
		elif model.time - ally.hurt < .25:
			state = "hurt"
			elapsed = model.time - ally.hurt
		var frame := library.motion_frame(ally.id, state, elapsed, marker, duration)
		var look: Array = ally.stats.get("look_tint", [1,1,1,1])
		var tint := Color(look[0],look[1],look[2], .45 if ally.hp <= 0 else 1)
		library.draw_actor(self, frame, foot, ally.stats.weapon, tint, state != "death", .43)
		_bar(foot + Vector2(-27, 5), ally.hp / ally.stats.hp, Color("8cdac2"))
		if ally.barrier > 0: draw_arc(foot - Vector2(0, 45), 42, PI, TAU, 24, Color(.6,.85,1,.7), 2, true)
	func _enemy(index: int, library: FrameLibrary) -> void:
		var enemy: Dictionary = model.enemies[index]
		var foot: Vector2 = ENEMY_FEET[index]
		var alpha := 1.0 if enemy.hp > 0 else .15
		var texture: Texture2D = library.textures["enemy_" + enemy.type]
		var spec: Dictionary = library.enemy_specs[enemy.type]
		var pose := "idle"
		var elapsed: float = model.time
		if not enemy.action.is_empty():
			pose = "charge" if not enemy.action.hit else "slam"
			elapsed = model.time - enemy.action.started
		if enemy.type == "golem":
			spec = library.guardian_frame(pose, elapsed)
			texture = library.textures[spec.file]
		elif library.painted.get("enemy_clips", {}).has(enemy.type):
			spec = library.enemy_frame(enemy.type, pose, elapsed)
			texture = library.textures[spec.file]
		var factor := (135.0 if enemy.boss else 90.0) / texture.get_height()
		var anchor := Vector2(spec.anchor[0], spec.anchor[1])
		draw_texture_rect(texture, Rect2(foot - anchor * factor, texture.get_size() * factor), false, Color(1, .83 if enemy.elite else 1.0, .75 if enemy.elite else 1.0, alpha))
		_bar(foot + Vector2(-27, 5), enemy.hp / enemy.max_hp, Color("dd918c"))
		draw_string(ThemeDB.fallback_font, foot + Vector2(-30, 18), "BOSS" if enemy.boss else enemy.name, HORIZONTAL_ALIGNMENT_LEFT, 96, 10, Color("e5cd9e"))
		if model.focus == index and enemy.hp > 0: draw_arc(foot - Vector2(0, 25), 28, 0, TAU, 24, Color("e5c278"), 2, true)
		if enemy.boss and enemy.mechanic == "shield" and not enemy.shield_broken: draw_arc(foot - Vector2(0, 60), 45, PI, TAU, 24, Color(.6,.8,1,.8), 3, true)
	func _bar(point: Vector2, value: float, color: Color) -> void:
		draw_rect(Rect2(point, Vector2(54, 4)), Color("1c3036"))
		draw_rect(Rect2(point, Vector2(54 * clampf(value,0,1), 4)), color)
