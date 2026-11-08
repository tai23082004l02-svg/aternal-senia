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
var portraits: Array[CharacterScreen.Face] = []
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
	for i in range(5):
		var box := Panel.new()
		box.position = Vector2(24 + i * 125, 371) if i < 4 else Vector2(24, 518)
		box.size = Vector2(117, 138) if i < 4 else Vector2(492, 52)
		box.add_theme_stylebox_override("panel", UIDesignV2.panel())
		add_child(box)
		if i < 4:
			var portrait := CharacterScreen.Face.new()
			portrait.frames = game.frames
			portrait.hero = "eira"
			portrait.position = Vector2(7,5)
			portrait.size = Vector2(44,44)
			portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
			box.add_child(portrait)
			portraits.append(portrait)
		names.append(game._label(box, "", Vector2(54,10) if i < 4 else Vector2(8,5),12 if i < 4 else 16,UIDesignV2.GOLD))
		names[-1].size = Vector2(60,38) if i < 4 else Vector2(160,24)
		names[-1].autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var hp := ProgressBar.new()
		hp.position = Vector2(8, 70)
		hp.size = Vector2(101, 7)
		hp.show_percentage = false
		box.add_child(hp)
		health.append(hp)
		hp_texts.append(game._label(box, "", Vector2(8, 53), 10))
		if i == 4:
			hp.hide()
			hp_texts[-1].position = Vector2(170,4)
		_bar_style(hp, Color("8bd6b6"))
		var nrg := ProgressBar.new()
		nrg.position = Vector2(8, 81) if i < 4 else Vector2(170, 23)
		nrg.size = Vector2(101, 7)
		nrg.show_percentage = false
		box.add_child(nrg)
		energy.append(nrg)
		_bar_style(nrg, Color("d4b56d"))
		var button: Button = game._button(box, "", Vector2(7, 94), Vector2(103, 42), _ultimate.bind(i))
		button.add_theme_font_size_override("font_size", 13)
		if i == 4:
			button.position = Vector2(318, 5)
			button.size = Vector2(166, 42)
		ultimates.append(button)
	auto_button = game._button(self, "", Vector2(24, 580), Vector2(148, 44), _auto)
	auto_button.add_theme_font_size_override("font_size", 14)
	speed_button = game._button(self, "×1", Vector2(180, 580), Vector2(64, 44), game._speed)
	pause_button = game._button(self, "Stop", Vector2(252, 580), Vector2(96, 44), game._toggle_pause)
	next_button = game._button(self, "", Vector2(356, 580), Vector2(160, 44), _next)
	next_button.add_theme_font_size_override("font_size", 14)
	game._button(self, "Retreat · No rewards", Vector2(24, 632), Vector2(492, 46), game._confirm_abandon)
	game._button(self, "Formation & Heroes", Vector2(24, 682), Vector2(492, 44), game._select_tab.bind(22))
	notice = game._label(self, "", Vector2(24, 728), 10)
	notice.size = Vector2(492, 14)
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
	heading.text = "STAGE %s · %s · %02d:%02d · Wave %d/%d" % [code, model.stage.name, int(model.time) / 60, int(model.time) % 60, model.wave + 1, model.wave_count()]
	heading.add_theme_font_size_override("font_size", 14)
	var can_play := model.state == "battle" and not model.paused and game.modal == null
	for i in range(5):
		if i < Formation.HERO_LIMIT:
			if i >= model.allies.size():
				portraits[i].visible = false
				names[i].text = "Empty slot"
				hp_texts[i].text = "No hero"
				health[i].value = 0
				energy[i].value = 0
				ultimates[i].text = "Unassigned"
				ultimates[i].disabled = true
				continue
			var ally: Dictionary = model.allies[i]
			portraits[i].visible = true
			portraits[i].hero = ally.id
			portraits[i].queue_redraw()
			names[i].text = game.catalog.find_row("heroes", ally.id).name
			hp_texts[i].text = "%d / %d HP" % [ally.hp, ally.stats.hp]
			health[i].value = ally.hp / ally.stats.hp * 100
			energy[i].value = ally.energy
			ultimates[i].text = "Defeated" if ally.hp <= 0 else "Energy %d%%" % ally.energy
			if ally.get("ultimate_queued", false) and ally.hp > 0: ultimates[i].text = "Queued"
			ultimates[i].disabled = not can_play or ally.hp <= 0 or ally.energy < 100 or not ally.action.is_empty()
		else:
			names[i].text = game.catalog.find_row("assists", model.stats.assist).name
			hp_texts[i].text = "Team Support"
			health[i].visible = false
			energy[i].value = model.spirit_energy
			ultimates[i].text = "Energy %d%%" % model.spirit_energy
			ultimates[i].disabled = not can_play or model.spirit_energy < 100 or not model.spirit_action.is_empty()
	auto_button.text = "AUTO ULT: " + ("ON" if model.auto_ultimate else "OFF")
	next_button.text = "Auto Advance: " + ("On" if model.auto_next else "Off")
	speed_button.text = "×%d" % model.speed
	pause_button.text = "Continue" if model.paused else "Stop"
	notice.text = model.warning() + " · Tap an enemy to target"

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
		if index == Formation.HERO_LIMIT: game.battle.spirit_ultimate()
		else: game.battle.ultimate(index)
func _auto() -> void:
	if game.battle is TeamBattle: game.battle.auto_ultimate = not game.battle.auto_ultimate
func _next() -> void:
	if game.battle is TeamBattle: game.battle.auto_next = not game.battle.auto_next

class TeamField extends Control:
	var game
	var model: TeamBattle
	const ALLY_FEET := [Vector2(211, 190), Vector2(211, 304), Vector2(88, 190), Vector2(88, 304)]
	const LEGACY_ALLY_FEET := [Vector2(213, 273), Vector2(102, 200), Vector2(92, 310)]
	func ally_feet() -> Array:
		return LEGACY_ALLY_FEET if model.run.team.version == 1 else ALLY_FEET
	func ally_point(index: int) -> Vector2:
		return model.allies[index].pos if model is ArenaBattle else ally_feet()[model.allies[index].slot]
	func enemy_point(index: int) -> Vector2:
		return model.enemies[index].pos if model is ArenaBattle else ENEMY_FEET[index]
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
				var d: float = event.position.distance_to(enemy_point(i) - Vector2(0, 32))
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
		var font := UIFonts.font("medium")
		draw_string(font, Vector2(20, 22), "OUR TEAM", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ecd095"))
		draw_string(font, Vector2(407, 22), "ENEMIES", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("ecd095"))
		if model is ArenaBattle: _arena_ground()
		var order := []
		for i in range(model.allies.size()): order.append({"enemy":false,"index":i,"y":ally_point(i).y})
		for i in range(model.enemies.size()): order.append({"enemy":true,"index":i,"y":enemy_point(i).y})
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
			var point: Vector2 = event.get("arena_point", ally_point(event.target) if ally_target else enemy_point(event.target))
			var color := Color("87e6b5") if event.kind == "heal" else (Color("ffcb78") if event.kind == "critical" else Color("f5ddd2"))
			color.a = 1 - age / .7
			if options.damage_numbers: draw_string(font, point + Vector2(-10, -82 - age * 25), event.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, color)
			if age < .18 and options.quality != "low" and options.lighting and not options.reduced_effects and not options.battery_saver:
				CombatEffects.stamp(self, library, "heal_ring" if event.kind == "heal" else "impact", point - Vector2(0,35), Vector2.ONE * 65, 1 - age / .18)
				if options.quality == "high": draw_arc(point - Vector2(0, 35), 12 + age * 80, 0, TAU, 16, color, 2, true)
	func _ally(index: int, library: FrameLibrary) -> void:
		var ally: Dictionary = model.allies[index]
		var foot: Vector2 = ally_point(index)
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
			if last.kind != "heal" and not model is ArenaBattle:
				var kit: Dictionary = ally.stats.get("combat",{})
				var force := .55 if last.kind == "ultimate" and kit.get("ultimate") == "execute" else (.08 if kit.get("basic") == "shield_ally" else .25)
				foot.x += CombatPresentation.lunge(elapsed,marker,duration)*force
		elif model.time - ally.hurt < .25:
			state = "hurt"
			elapsed = model.time - ally.hurt
		if model is ArenaBattle and ally.hp > 0 and ally.get("moving", false) and ally.action.is_empty() and model.state == "battle" and model.move_clock <= 0:
			state = "run"
			elapsed = model.time
		var frame := library.motion_frame(ally.id, state, elapsed, marker, duration)
		var look: Array = ally.stats.get("look_tint", [1,1,1,1])
		var tint := Color(look[0],look[1],look[2], .45 if ally.hp <= 0 else 1)
		draw_ellipse_shadow(foot, Color(0, 0, 0, .24))
		library.draw_actor(self, frame, foot, ally.stats.weapon, tint, state != "death", .23 if model is ArenaBattle else .43, ally.get("face", 1.0))
		_bar(foot + Vector2(-27, 5), ally.hp / ally.stats.hp, Color("8cdac2"))
		if model is ArenaBattle: _bar(foot + Vector2(-27, 11), ally.energy / 100, Color("d4b56d"))
		if ally.barrier > 0: draw_arc(foot - Vector2(0, 45), 42, PI, TAU, 24, Color(.6,.85,1,.7), 2, true)
	func _enemy(index: int, library: FrameLibrary) -> void:
		var enemy: Dictionary = model.enemies[index]
		var foot: Vector2 = enemy_point(index)
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
		var factor := ((106.0 if enemy.boss else 74.0) if model is ArenaBattle else (135.0 if enemy.boss else 90.0)) / texture.get_height()
		var anchor := Vector2(spec.anchor[0], spec.anchor[1])
		var origin := foot - anchor * factor
		var dimensions := texture.get_size() * factor
		if model is ArenaBattle and enemy.face > 0:
			origin.x = foot.x + anchor.x * factor
			dimensions.x = -dimensions.x
		draw_ellipse_shadow(foot, Color(0, 0, 0, .24 * alpha))
		draw_texture_rect(texture, Rect2(origin, dimensions), false, Color(1, .83 if enemy.elite else 1.0, .75 if enemy.elite else 1.0, alpha))
		_bar(foot + Vector2(-27, 5), enemy.hp / enemy.max_hp, Color("dd918c"))
		draw_string(UIFonts.font("display") if enemy.boss else UIFonts.font("medium"), foot + Vector2(-30, 18), "BOSS" if enemy.boss else UIFonts.enemy_name(enemy.name), HORIZONTAL_ALIGNMENT_LEFT, 96, 10, Color("e5cd9e"))
		if model.focus == index and enemy.hp > 0: draw_arc(foot - Vector2(0, 25), 28, 0, TAU, 24, Color("e5c278"), 2, true)
		if enemy.boss and enemy.mechanic == "shield" and not enemy.shield_broken: draw_arc(foot - Vector2(0, 60), 45, PI, TAU, 24, Color(.6,.8,1,.8), 3, true)
	func draw_ellipse_shadow(point: Vector2, color: Color) -> void:
		if not model is ArenaBattle: return
		draw_set_transform(point, 0, Vector2(1, .28))
		draw_circle(Vector2.ZERO, 22, color)
		draw_set_transform(Vector2.ZERO)
	func _arena_ground() -> void:
		var options: Dictionary = game.presentation_options
		# The entire arena, danger zones and bolts read simulation state only.
		draw_rect(Rect2(22, 105, 496, 218), Color(.04, .10, .14, .22))
		for enemy in model.enemies:
			if enemy.hp <= 0 or enemy.action.is_empty() or enemy.action.hit: continue
			var point: Vector2 = enemy.action.point
			var radius: float = enemy.action.radius
			var charge := clampf((model.time - enemy.action.started) / enemy.action.marker, 0, 1)
			draw_circle(point, radius, Color(.9, .25, .15, .14))
			draw_arc(point, radius, 0, TAU, 40, Color(1, .57, .32, .85), 2, true)
			draw_arc(point, radius * .85, -PI / 2, -PI / 2 + TAU * charge, 32, Color(1, .78, .5, .8), 2, true)
		for shot in model.projectiles:
			var point: Vector2 = shot.pos - Vector2(0, 30)
			var tail: Vector2 = point - shot.velocity.normalized() * 20
			draw_line(tail, point, Color(.4, .85, 1, .8), 3, true)
			draw_circle(point, 4, Color(.8, 1, 1))
			if options.lighting and not options.reduced_effects: draw_circle(point, 8, Color(.3, .8, 1, .18))
	func _bar(point: Vector2, value: float, color: Color) -> void:
		draw_rect(Rect2(point, Vector2(54, 4)), Color("1c3036"))
		draw_rect(Rect2(point, Vector2(54 * clampf(value,0,1), 4)), color)
