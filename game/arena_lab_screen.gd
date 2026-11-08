class_name ArenaLabScreen
extends VBoxContainer

var game
var model: ArenaExhibition
var field: ExhibitionField
var status: Label
var start_button: Button
var setup: VBoxContainer
var selectors: Array = [[],[]]
var seed_input: SpinBox
var durability: OptionButton
var full_energy: CheckButton
var cursor := 0
var backgrounded := false

func _ready() -> void:
	custom_minimum_size.x = 492
	add_theme_constant_override("separation",8)
	var header := HBoxContainer.new()
	add_child(header)
	game._button(header,"‹ Dungeons",Vector2.ZERO,Vector2(130,44),game._select_tab.bind(21))
	var title := words(header,"ARENA",27)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words(self,"Choose both teams and watch AI combat. All runtime heroes can be previewed here. No rewards or progress changes.",14)
	field = ExhibitionField.new()
	field.game = game
	field.screen = self
	field.custom_minimum_size = Vector2(492,320)
	field.clip_contents = true
	field.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(field)
	status = words(self,"Set up a match below.",16)
	var controls := HBoxContainer.new()
	controls.add_theme_constant_override("separation",6)
	add_child(controls)
	start_button = game._button(controls,"Start",Vector2.ZERO,Vector2(110,44),_start_or_pause)
	game._button(controls,"Speed ×1",Vector2.ZERO,Vector2(110,44),_speed)
	game._button(controls,"Replay",Vector2.ZERO,Vector2(110,44),_start)
	game._button(controls,"Setup",Vector2.ZERO,Vector2(140,44),_setup)
	setup = VBoxContainer.new()
	setup.add_theme_constant_override("separation",8)
	add_child(setup)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation",12)
	setup.add_child(columns)
	for side in range(2):
		var column := VBoxContainer.new()
		column.custom_minimum_size.x = 240
		columns.add_child(column)
		words(column,"TEAM " + ["A","B"][side],19)
		for slot in range(4):
			var choice := OptionButton.new()
			choice.custom_minimum_size = Vector2(240,44)
			choice.mouse_filter = Control.MOUSE_FILTER_PASS
			choice.add_item("Slot %d · Empty" % (slot+1))
			for hero in game.catalog.data.heroes: choice.add_item(hero.name)
			choice.select(_selection_index(game.arena_setup.teams[side][slot]))
			choice.item_selected.connect(_selection_changed.bind(side,slot))
			column.add_child(choice)
			selectors[side].append(choice)
	var settings := HBoxContainer.new()
	setup.add_child(settings)
	words(settings,"Seed",14)
	seed_input = SpinBox.new()
	seed_input.min_value = 1
	seed_input.max_value = 999999
	seed_input.value = game.arena_setup.seed
	seed_input.custom_minimum_size = Vector2(150,44)
	settings.add_child(seed_input)
	durability = OptionButton.new()
	durability.custom_minimum_size = Vector2(190,44)
	for label in ["Practice HP ×1","Practice HP ×3","Practice HP ×5"]: durability.add_item(label)
	durability.select([1,3,5].find(game.arena_setup.durability))
	settings.add_child(durability)
	full_energy = CheckButton.new()
	full_energy.text = "Start with full Energy · Preview Ultimates"
	full_energy.button_pressed = game.arena_setup.full_energy
	full_energy.custom_minimum_size.y = 44
	setup.add_child(full_energy)
	words(setup,"Uses current hero builds. Practice HP affects this match only; no spirits or consumables.",13)

func words(parent: Node, text: String, font_size: int) -> Label:
	var label: Label = game._label(parent,text,Vector2.ZERO,font_size)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _selection_index(id: String) -> int:
	for i in range(game.catalog.data.heroes.size()):
		if game.catalog.data.heroes[i].id == id: return i+1
	return 0

func _selection_changed(index: int, side: int, slot: int) -> void:
	game.arena_setup.teams[side][slot] = "" if index == 0 else game.catalog.data.heroes[index-1].id

func _start_or_pause() -> void:
	if model == null or model.state != "battle": _start()
	else: model.paused = not model.paused

func _start() -> void:
	var rosters := []
	for side in range(2): rosters.append(game.arena_setup.teams[side].filter(func(id): return not id.is_empty()))
	game.arena_setup.seed = int(seed_input.value)
	game.arena_setup.durability = [1,3,5][durability.selected]
	game.arena_setup.full_energy = full_energy.button_pressed
	var candidate := ArenaExhibition.new(game.catalog)
	if not candidate.start_match(game.store.profile,rosters,game.arena_setup.seed,game.arena_setup.durability,full_energy.button_pressed):
		status.text = "Choose 1–4 different heroes per team. The same hero may face themselves."
		return
	model = candidate
	cursor = 0
	start_button.text = "Pause"
	status.text = "00:00 · AI vs AI · Fighting"
	start_button.get_parent().get_child(1).text = "Speed ×1"
	setup.hide()
	game.scroll.scroll_vertical = 0
	field.custom_minimum_size.y = 350

func _setup() -> void:
	if model != null: model.paused = true
	setup.show()
	field.custom_minimum_size.y = 320

func _speed() -> void:
	if model == null: return
	model.speed = 2 if model.speed == 1 else 1
	start_button.get_parent().get_child(1).text = "Speed ×%d" % model.speed

func _process(delta: float) -> void:
	if game.tab != 25: return
	if model != null:
		if game.modal == null and not backgrounded: model.advance(delta)
		for event in model.events:
			if event.id <= cursor: continue
			cursor = event.id
			if not event.cue.is_empty(): game.audio.play(event.cue)
		start_button.text = "Replay" if model.state != "battle" else ("Resume" if model.paused else "Pause")
		status.text = ("Draw" if model.winner < 0 else "Team %s wins" % ["A","B"][model.winner]) if model.state != "battle" else "%02d:%02d · AI vs AI · %s" % [int(model.time)/60,int(model.time)%60,"Paused" if model.paused else "Fighting"]
	field.queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED: backgrounded = true
	elif what == NOTIFICATION_APPLICATION_RESUMED: backgrounded = false

func _exit_tree() -> void:
	if is_instance_valid(game) and is_instance_valid(game.audio) and not game.audio.shutting_down:
		game.audio.stop_world()
	model = null

class ExhibitionField extends Control:
	var game
	var screen: ArenaLabScreen
	var background: Texture2D = preload("res://art/arena/celestial_courtyard.png")
	func _draw() -> void:
		draw_texture_rect(background,Rect2(Vector2.ZERO,size),false)
		var battle: ArenaExhibition = screen.model
		if battle == null:
			draw_string(UIFonts.font("display"),Vector2(24,38),"CELESTIAL COURTYARD",HORIZONTAL_ALIGNMENT_LEFT,-1,19,Color("fff0c0"))
			return
		var scale_value := size/Vector2(540,330)
		draw_set_transform(Vector2.ZERO,0,scale_value)
		var order: Array = battle.teams[0]+battle.teams[1]
		for side in range(2):
			for unit in battle.teams[side]:
				if unit.action.is_empty() or unit.action.hit or unit.hp <= 0: continue
				var color := Color(.25,.65,1,.5) if side == 0 else Color(1,.35,.2,.5)
				draw_arc(unit.action.point,unit.action.radius,0,TAU,32,color,2,true)
		for shot in battle.projectiles:
			var point: Vector2 = shot.pos-Vector2(0,30)
			draw_line(point-shot.velocity.normalized()*20,point,Color(.5,.9,1),3,true)
			draw_circle(point,5,Color(.85,1,1))
		order.sort_custom(func(a,b): return a.pos.y < b.pos.y)
		for unit in order:
			var foot: Vector2 = unit.pos
			var state := "idle"
			var elapsed: float = battle.time
			var marker := -1.0
			var duration := -1.0
			if unit.hp <= 0:
				state = "death"
				elapsed = battle.time-unit.hurt
			elif not unit.action.is_empty():
				state = "attack" if unit.action.kind == "attack" else "skill"
				elapsed = battle.time-unit.action.started
				marker = unit.action.marker
				duration = unit.action.duration
			elif unit.moving and battle.state == "battle": state = "run"
			elif battle.time-unit.hurt < .25:
				state = "hurt"
				elapsed = battle.time-unit.hurt
			var frame: Dictionary = game.frames.motion_frame(unit.stats.hero,state,elapsed,marker,duration)
			draw_set_transform(Vector2.ZERO,0,scale_value)
			var tint_data: Array = unit.stats.get("look_tint",[1,1,1,1])
			var tint := Color(tint_data[0],tint_data[1],tint_data[2],.4 if unit.hp <= 0 else 1)
			# Draw actors in viewport coordinates; use a uniform actor scale.
			draw_set_transform(Vector2.ZERO)
			game.frames.draw_actor(self,frame,foot*scale_value,unit.stats.weapon,tint,state != "death",.23*scale_value.x,unit.face)
			draw_set_transform(Vector2.ZERO,0,scale_value)
			var team_color := Color("85d8ef") if unit.id < 4 else Color("f5a18d")
			draw_rect(Rect2(foot+Vector2(-27,5),Vector2(54,5)),Color("142337"))
			draw_rect(Rect2(foot+Vector2(-27,5),Vector2(54*unit.hp/unit.stats.hp,5)),team_color)
			draw_rect(Rect2(foot+Vector2(-27,12),Vector2(54*unit.energy/100,3)),Color("e4bd6c"))
			var name_point := Vector2(clampf(foot.x-30,0,450),minf(foot.y+17,314))
			draw_rect(Rect2(name_point,Vector2(90,16)),Color(.035,.06,.12,.83))
			draw_string(UIFonts.font("medium"),name_point+Vector2(3,11),"%s · %s" % ["A" if unit.id < 4 else "B",game.catalog.find_row("heroes",unit.stats.hero).name],HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("fff0cd"))
			if unit.barrier > 0: draw_arc(foot-Vector2(0,35),34,PI,TAU,20,Color(.5,.85,1,.75),2,true)
			var last: Dictionary = unit.last
			if not last.is_empty() and last.kind != "attack" and not game.presentation_options.reduced_effects and game.presentation_options.lighting:
				var age: float = battle.time-last.started-last.marker
				if age >= 0 and age < .45:
					var point: Vector2 = (foot if last.kind == "heal" or last.point.x < 0 else last.point)-Vector2(0,30)
					draw_set_transform(Vector2.ZERO)
					CombatEffects.stamp(self,game.frames,"heal_ring" if last.kind == "heal" else "slash_gold",point*scale_value,Vector2(100,60)*scale_value,.65*(1-age/.45))
					draw_set_transform(Vector2.ZERO,0,scale_value)
		for event in battle.events:
			var age: float = battle.time-event.time
			if age < 0 or age > .65 or event.target < 0 or event.kind not in ["hurt","heal","guard"]: continue
			var color := Color(.5,1,.7,1-age/.65) if event.kind == "heal" else Color(1,.7,.4,1-age/.65)
			if game.presentation_options.damage_numbers: draw_string(UIFonts.font("medium"),event.point+Vector2(-15,-70-age*20),event.text,HORIZONTAL_ALIGNMENT_LEFT,-1,15,color)
			if age < .18 and not game.presentation_options.reduced_effects:
				draw_arc(event.point-Vector2(0,30),12+age*80,0,TAU,16,color,2,true)
				if game.presentation_options.lighting:
					draw_set_transform(Vector2.ZERO)
					CombatEffects.stamp(self,game.frames,"heal_ring" if event.kind == "heal" else "impact",(event.point-Vector2(0,30))*scale_value,Vector2.ONE*45,.7*(1-age/.18))
					draw_set_transform(Vector2.ZERO,0,scale_value)
		draw_set_transform(Vector2.ZERO)
