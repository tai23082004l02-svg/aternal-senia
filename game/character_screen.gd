class_name CharacterScreen
extends Control

const SECTIONS := ["Information", "Equipment", "Enhance", "Awakening", "Evolve", "Skills", "Wardrobe"]
const ICONS := ["hero", "equipment", "training", "awakening", "evolution", "talents", "wardrobe"]
var game
var hero := "eira"
var section := 0
var body: VBoxContainer
var detail_scroll: ScrollContainer
var faces: Array[Button] = []
var face_buttons: Dictionary = {}
var section_buttons: Array[Button] = []

const TAB_NAMES := ["Information", "Equipment", "Progression", "Skills", "Wardrobe"]
const TAB_PAGES := [0, 1, 2, 5, 6]
const TAB_ICONS := ["journal", "equipment", "evolution", "talents", "wardrobe"]
var development_buttons: Array[Button] = []

func _ready() -> void:
	custom_minimum_size = Vector2(492, 732)
	var gallery_button: Button = game._button(self, "Gallery →", Vector2(0, 78), Vector2(66, 34), game._select_tab.bind(23))
	gallery_button.name = "OpenGallery"
	gallery_button.add_theme_font_size_override("font_size", 11)
	var roster := VBoxContainer.new()
	roster.position = Vector2(0, 120)
	roster.size = Vector2(66, 600)
	roster.add_theme_constant_override("separation", 10)
	add_child(roster)
	var roster_rows: Array = game.catalog.data.heroes.duplicate()
	roster_rows.sort_custom(func(a,b): return a.gallery_order < b.gallery_order)
	for row in roster_rows:
		var face_button: Button = game._button(roster, "", Vector2.ZERO, Vector2(66, 96), game._inspect_character.bind(row.id))
		var owned: bool = game.store.available_hero(row.id)
		face_button.tooltip_text = row.name + ("" if owned else " · Not owned")
		var face := Face.new()
		face.frames = game.frames
		face.hero = row.id
		face.dimmed = not owned
		face.selection_avatar = true
		face.position = Vector2(3, 2)
		face.size = Vector2(60, 60)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		face_button.add_child(face)
		var name_label: Label = game._label(face_button, row.name, Vector2(0, 64), 12, Color("e8d7ac"))
		name_label.size.x = 66
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var level: Label = game._label(face_button, "LV%d" % game.store.profile.heroes[row.id].level if owned else "None yet", Vector2(0, 80), 11)
		level.size.x = 66
		level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if row.id == hero: face_button.add_theme_stylebox_override("normal", gold_style(true))
		faces.append(face_button)
		face_buttons[row.id] = face_button
	var menu := HBoxContainer.new()
	menu.position = Vector2.ZERO
	menu.size = Vector2(492, 66)
	menu.add_theme_constant_override("separation", 6)
	add_child(menu)
	for i in range(TAB_NAMES.size()):
		var b: Button = game._button(menu, TAB_NAMES[i], Vector2.ZERO, Vector2(93, 66), game._character_section.bind(TAB_PAGES[i]))
		game.icons.tab(b, TAB_ICONS[i])
		b.custom_minimum_size = Vector2(93, 66)
		b.size = Vector2(93, 66)
		b.get_child(1).position.y = 39
		b.get_child(1).add_theme_font_size_override("font_size", 11)
		if section == TAB_PAGES[i] or i == 2 and section in [2,3,4]: b.add_theme_stylebox_override("normal", gold_style(true))
		section_buttons.append(b)
	var frame := PanelContainer.new()
	frame.position = Vector2(76, 78)
	frame.size = Vector2(416, 642)
	frame.add_theme_stylebox_override("panel", game._style(Color(.035,.1,.14,.87), Color("69715f"), 13))
	add_child(frame)
	detail_scroll = SwipeScroll.new()
	detail_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	frame.add_child(detail_scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 8)
	detail_scroll.add_child(body)
	if section in [0,1]:
		frame.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
		body.add_theme_constant_override("separation",0)
		var page := CharacterPanelPage.new()
		page.game = game
		page.hero = hero
		page.equipment_page = section == 1
		body.add_child(page)
		return
	var p: Dictionary = game.store.profile
	var row: Dictionary = game.catalog.find_row("heroes", hero)
	var heading := HBoxContainer.new()
	body.add_child(heading)
	var element := TextureRect.new()
	element.texture = game.icons.textures.get(row.element, game.icons.textures.light)
	element.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	element.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	element.custom_minimum_size = Vector2(30, 39)
	heading.add_child(element)
	var title := VBoxContainer.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	game._label(title, row.name, Vector2.ZERO, 24, Color("f1dfb0"))
	game._label(title, row.title, Vector2.ZERO, 12, Color("a8c6c8"))
	game._button(heading, "?", Vector2.ZERO, Vector2(30, 30), game._character_help).add_theme_font_size_override("font_size", 13)
	text("★".repeat(Recruitment.rarity("hero", hero, game.catalog)), 18, Color("efbf67"))
	if not game.store.available_hero(hero):
		text("Not owned · " + row.acquisition, 12)
		button("Go to Shop →", game._select_tab.bind(20))
	if section in [2,3,4]:
		var development := HBoxContainer.new()
		development.add_theme_constant_override("separation", 6)
		body.add_child(development)
		for pair in [["Upgrade",2],["Evolve",4],["Awaken",3]]:
			var b: Button = game._button(development, pair[0], Vector2.ZERO, Vector2(116, 37), game._character_section.bind(pair[1]))
			b.add_theme_font_size_override("font_size", 13)
			if section == pair[1]: b.add_theme_stylebox_override("normal", gold_style(true))
			development_buttons.append(b)
	match section:
		2: levels()
		3: stars_panel()
		4: evolution()
		5: skills()
		6: outfits()

func gold_style(active: bool = false) -> StyleBoxFlat:
	var style = game._style(Color("493c25") if active else Color("142e3a"), Color("dfbc72") if active else Color("60716b"), 11)
	if active:
		style.shadow_color = Color(1,.66,.2,.25)
		style.shadow_size = 6
	return style

func text(value: String, font_size: int = 14, color: Color = Color("c0d0cb")) -> Label:
	var label := Label.new()
	label.text = value
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.custom_minimum_size.x = 350
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	body.add_child(label)
	return label

func button(title: String, action: Callable, disabled: bool = false) -> Button:
	var b: Button = game._button(body, title, Vector2.ZERO, Vector2(350, 44), action)
	b.add_theme_font_size_override("font_size", 13)
	b.clip_text = true
	b.tooltip_text = title
	b.disabled = disabled
	game.icons.action(b, action)
	return b

func locked() -> bool:
	return game._locked() or not game.store.available_hero(hero)

func portrait(height: int = 245) -> void:
	var stage := Control.new()
	stage.custom_minimum_size = Vector2(350, height)
	body.add_child(stage)
	make_portrait(stage, height)

func make_portrait(parent: Control, height: int) -> HeroPortrait:
	var view := HeroBanner.new()
	view.library = game.frames
	view.hero = hero
	view.weapon = game.catalog.stats(game.store.profile, hero).weapon
	view.interactive = game.store.available_hero(hero) and Recruitment.rarity("hero", hero, game.catalog) == 5
	view.fit_actor = true
	view.palette_tint = Wardrobe.tint(game.store.profile, hero)
	if section == 6 and game.character_outfit_preview in Wardrobe.LOOKS: view.palette_tint = Wardrobe.LOOKS[game.character_outfit_preview].tint
	view.custom_minimum_size = Vector2(230, height)
	parent.add_child(view)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view.tooltip_text = "" if view.interactive else "Hero not owned"
	return view

func stats_line(p: Dictionary) -> void:
	var stats: Dictionary = game.catalog.stats(p, hero)
	text("HP %.0f\nATK %.1f\nDEF %.2f\nCritical Rate %.0f%%" % [stats.hp, stats.atk, stats.defense, stats.crit * 100], 15)

func preview(next: Dictionary) -> void:
	var current: Dictionary = game.catalog.stats(game.store.profile, hero)
	var after: Dictionary = game.catalog.stats(next, hero)
	text("UPGRADED STATS", 14, Color("e5cd9e"))
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", gold_style())
	body.add_child(panel)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 18)
	grid.add_theme_constant_override("v_separation", 10)
	panel.add_child(grid)
	for pair in [["HP","hp"],["ATK","atk"],["DEF","defense"]]:
		for value in [pair[0], str(snappedf(current[pair[1]], .01)), "→  " + str(snappedf(after[pair[1]], .01))]:
			var label := Label.new()
			label.text = value
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			label.add_theme_font_size_override("font_size", 14)
			if value.begins_with("→"): label.modulate = Color("a4dfa5")
			grid.add_child(label)

func resource_tiles(entries: Array) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	body.add_child(row)
	for entry in entries:
		var panel := PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", gold_style())
		row.add_child(panel)
		var column := VBoxContainer.new()
		panel.add_child(column)
		var image := TextureRect.new()
		image.texture = game.icons.textures[entry[0]]
		image.custom_minimum_size = Vector2(46,46)
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		column.add_child(image)
		var label := Label.new()
		label.text = "%d / %d" % [entry[1],entry[2]]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 12)
		label.modulate = Color("b6ddb4") if entry[1] >= entry[2] else Color("dfb895")
		column.add_child(label)

func levels() -> void:
	var p: Dictionary = game.store.profile
	var level: int = p.heroes[hero].level
	text("LV %d/100" % level, 26, Color("f0ddb2")).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var experience := ProgressBar.new()
	experience.value = minf(100, float(p.xp) / maxi(1, level*15) * 100)
	experience.show_percentage = false
	experience.custom_minimum_size.y = 14
	var background := StyleBoxFlat.new()
	background.bg_color = Color("203d49")
	background.set_corner_radius_all(6)
	var fill := background.duplicate()
	fill.bg_color = Color("b5a265")
	experience.add_theme_stylebox_override("background",background)
	experience.add_theme_stylebox_override("fill",fill)
	body.add_child(experience)
	text("Available XP: %d / %d needed for next LV" % [p.xp, level*15], 12)
	if level >= 100:
		text("Maximum LV 100 reached", 16, Color("e5cd9e"))
		stats_line(p)
		return
	var next: Dictionary = p.duplicate(true)
	next.heroes[hero].level += 1
	preview(next)
	text("Gain 2 Attribute Points per level.", 13)
	resource_tiles([["xp",p.xp,level*15],["gold",p.gold,level*30]])
	button("Gain 1 LV", game._character_level.bind(hero, 1), locked() or p.gold < level * 30 or p.xp < level * 15)
	var count := mini(5, 100 - level)
	var total: int = count * level + count * (count - 1) / 2
	text("Gain %d LV: %d Gold + %d XP" % [count, total * 30, total * 15], 13)
	button("Gain %d LV" % count, game._character_level.bind(hero, count), locked() or p.gold < total * 30 or p.xp < total * 15)

func stars_panel() -> void:
	var p: Dictionary = game.store.profile
	var r := Recruitment.state(p)
	var stars: int = r.awakening[hero]
	text("AWAKENING · GAIN STARS", 16, Color("e5cd9e"))
	text("Use matching Hero Fragments to gain Awakening Stars. Each star adds 30 HP, 3 ATK, and 1 DEF, independently of base rarity and existing interactions.", 13)
	if stars >= 5:
		text("Maximum 5 Awakening Stars reached.", 15)
		return
	var next: Dictionary = p.duplicate(true)
	Recruitment.ensure(game.store, next)
	next.recruitment.awakening[hero] += 1
	preview(next)
	text("Requires LV %d · Current %d\nFragments %d / %d\nGold %d / %d" % [stars * 10, p.heroes[hero].level, r.fragments[hero], stars * 20, p.gold, stars * 200])
	button("Awakening Stars %d → %d" % [stars, stars + 1], game._character_stars.bind(hero), locked() or p.heroes[hero].level < stars * 10 or r.fragments[hero] < stars * 20 or p.gold < stars * 200)

func evolution() -> void:
	var p: Dictionary = game.store.profile
	var tier := HeroEvolution.rank(p, hero)
	text("EVOLUTION · RANK %d/3" % tier, 16, Color("a2e5d6"))
	text("Each rank adds 8% HP, ATK, and DEF. Separate from Awakening Stars; uses Crystals and Spirit Cores.", 13)
	if tier >= 3:
		text("Maximum evolution reached.")
		return
	var next: Dictionary = p.duplicate(true)
	if not next.has("evolution"): next.evolution = HeroEvolution.fresh()
	next.evolution[hero] += 1
	preview(next)
	text("Requires LV %d · Current %d\nAwakening Stars %d · Current %d\nGold %d / %d\nCrystals %d / %d\nCores %d / %d" % [tier * 15, p.heroes[hero].level, tier + 1, Recruitment.state(p).awakening[hero], p.gold, tier * 250, p.shards, tier * 10, p.expansion.cores, tier * 3])
	button("Evolve to rank %d" % (tier + 1), game._character_evolve.bind(hero), locked() or not HeroEvolution.eligible(game.store, hero))

func skills() -> void:
	var switch := HBoxContainer.new()
	switch.add_theme_constant_override("separation", 6)
	body.add_child(switch)
	for key in ["overview","tree"]:
		var b: Button = game._button(switch, "Skills" if key == "overview" else "Talents", Vector2.ZERO, Vector2(175,37), game._character_skill_view.bind(key))
		if game.character_skill_view == key: b.add_theme_stylebox_override("normal", gold_style(true))
	if game.character_skill_view == "tree":
		talents_tree()
		return
	var p: Dictionary = game.store.profile
	var unit: Dictionary = p.heroes[hero]
	for entry in [["Basic Attack","Automatically attack the priority target and build Energy on hits.","slash","Basic Attack"],["Basic Skill", game.catalog.find_row("heroes",hero).skill_descriptions.basic,"heal_spell" if hero == "mira" else "slash_spell","Skills"],["Ultimate", game.catalog.find_row("heroes",hero).skill_descriptions.ultimate,"burst","Ultimate"],["Traits", game.catalog.find_row("heroes",hero).passive,"water" if hero == "mira" else "talents","Passive"]]:
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", gold_style())
		body.add_child(panel)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		panel.add_child(row)
		var image := TextureRect.new()
		image.texture = game.icons.textures[entry[2]]
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(46,46)
		row.add_child(image)
		var col := VBoxContainer.new()
		col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(col)
		var name_label := Label.new()
		name_label.text = entry[0] if entry[0] == entry[3] else entry[0] + " · " + entry[3]
		name_label.add_theme_font_size_override("font_size", 15)
		name_label.modulate = Color("ead29d")
		col.add_child(name_label)
		var description := Label.new()
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		description.text = entry[1]
		description.add_theme_font_size_override("font_size", 12)
		col.add_child(description)
	for i in range(2):
		button("Upgrade %s · LV %d/10 · %d Gold" % ["damage skills" if i == 0 else "healing/shields",unit.skills[i],unit.skills[i]*25],game._character_skill_level.bind(hero,i),locked() or unit.skills[i]>=10 or p.gold<unit.skills[i]*25)
	button("Spirit skill tree →", game._select_tab.bind(13))

func talents_tree() -> void:
	var build: Dictionary = game.store.profile.expansion.builds[hero]
	var rows := []
	for row in game.catalog.data.talents:
		if row.slot < 2: rows.append(row)
	var tree := TalentMap.new()
	tree.custom_minimum_size = Vector2(350,280)
	tree.rows = rows
	tree.chosen = build.selected
	tree.learned = build.learned
	tree.game = game
	body.add_child(tree)
	var selected: Dictionary = {}
	for row in rows:
		if row.id == game.character_talent_focus: selected = row
	if selected.is_empty(): selected = rows[0]
	var owned: bool = selected.id in build.learned
	var chosen: bool = build.selected[selected.slot] == selected.id
	text(selected.name + (" · Selected" if chosen else ""), 18, Color("e5cd9e"))
	text(selected.description, 14)
	text("Requires LV %d · %d Gold + %d Crystals" % [selected.level,selected.gold,selected.shards] if not owned else "Learned · Select or remove branches for free outside battle", 12)
	button("Deselect" if chosen else ("Choose branch" if owned else "Learn talent"),game._character_talent.bind(hero,selected.id),locked() or game.store.profile.heroes[hero].level < selected.level or not owned and (game.store.profile.gold<selected.gold or game.store.profile.shards<selected.shards))

func outfits() -> void:
	var p: Dictionary = game.store.profile
	var current := Wardrobe.selected(p, hero)
	var preview_id: String = game.character_outfit_preview if game.character_outfit_preview in Wardrobe.LOOKS else current
	portrait(300)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	body.add_child(row)
	for id in Wardrobe.LOOKS:
		var b: Button = game._button(row, "", Vector2.ZERO, Vector2(112,115),game._preview_character_outfit.bind(id))
		b.add_theme_stylebox_override("normal",gold_style(preview_id == id))
		var face := Face.new()
		face.frames = game.frames
		face.hero = hero
		face.modulate = Wardrobe.LOOKS[id].tint
		face.position = Vector2(30,4)
		face.size = Vector2(52,52)
		face.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(face)
		var name_label: Label = game._label(b,{"original":"Default","dawn":"Dawn","moon":"Moonlight"}[id],Vector2(0,64),12,Color("e7d3a5"))
		name_label.size.x = 112
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var status: Label = game._label(b,"✓ In Use" if id == current else "Preview",Vector2(0,87),10)
		status.size.x = 112
		status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text("Free color palettes change appearance only. New outfits are not available yet.",12)
	button("In use" if current == preview_id else "Apply Palette", game._apply_character_outfit.bind(hero,preview_id),locked() or current == preview_id)
	if hero == "ryn": button("View Ryn portrait →",game._show_ryn_portrait)

class Face extends Control:
	static var avatar_regions: Dictionary = {}
	static var avatar_texture: Texture2D
	var selection_avatar := false
	var frames: FrameLibrary
	var hero := "eira"
	var dimmed := false
	func _draw() -> void:
		if selection_avatar:
			if avatar_texture == null:
				var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://art/avatars/manifest.json"))
				avatar_regions = spec.regions
				avatar_texture = load("res://" + spec.source)
			if avatar_regions.has(hero):
				var region: Array = avatar_regions[hero]
				draw_texture_rect_region(avatar_texture, Rect2(Vector2.ZERO,size), Rect2(region[0],region[1],region[2],region[3]), Color(.45,.45,.45,1) if dimmed else Color.WHITE)
				return
		if frames.painted.get("portraits", {}).has(hero):
			var rect: Array = frames.painted.portraits[hero].face
			draw_texture_rect_region(frames.textures["portrait_" + hero], Rect2(Vector2.ZERO, size), Rect2(rect[0], rect[1], rect[2], rect[3]), Color(.5, .5, .5, 1) if dimmed else Color.WHITE)
			return
		var frame := frames.frame_at(hero, "idle", 0)
		var region := Rect2(95, 0, 135, 135) if hero in ["eira", "mira", "lyra"] else Rect2(48, 25, 96, 100)
		draw_texture_rect_region(frames.textures[frame.file], Rect2(Vector2.ZERO, size), region, Color(.5, .5, .5, 1) if dimmed else Color.WHITE)

class MagicBackdrop extends Control:
	func _draw() -> void:
		var center := size * Vector2(.5,.52)
		var radius := minf(size.x*.4,size.y*.44)
		for r in [radius,radius*.86,radius*.68]: draw_arc(center,r,0,TAU,72,Color(.3,.62,.68,.23),1,true)
		for i in range(16):
			var direction := Vector2.from_angle(i*TAU/16)
			draw_line(center+direction*radius*.92,center+direction*radius,Color(.7,.65,.39,.25),1,true)

class TalentMap extends Control:
	var game
	var rows: Array
	var chosen: Array
	var learned: Array
	var nodes: Array[Button] = []
	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		for row in rows:
			var button: Button = game._button(self,"",Vector2.ZERO,Vector2(48,48),game._character_talent_focus.bind(row.id))
			button.tooltip_text = row.name
			button.add_theme_stylebox_override("normal",game._style(Color("294237") if row.id in chosen else Color("173442"),Color("dabe7d") if row.id == game.character_talent_focus or row.id in learned else Color("52747a"),24))
			var icon := TextureRect.new()
			icon.texture = game.icons.textures[{"focus":"slash","breaker":"spirit","restoration":"heal","barrier":"guard"}[row.id]]
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.position = Vector2(9,7)
			icon.size = Vector2(30,30)
			icon.modulate = Color.WHITE if row.id in learned else Color(.6,.7,.75)
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			button.add_child(icon)
			if row.id in chosen:
				var check: Label = game._label(button,"✓",Vector2(30,29),12,Color("a8edba"))
				check.mouse_filter = Control.MOUSE_FILTER_IGNORE
			nodes.append(button)
		_layout()
		resized.connect(_layout)
	func _layout() -> void:
		for i in range(nodes.size()): nodes[i].position = size*.5 + Vector2.from_angle(-PI*.5+i*TAU/nodes.size())*100 - Vector2(24,24)
		queue_redraw()
	func _draw() -> void:
		var center := size*.5
		for radius in [76,100,122]: draw_arc(center,radius,0,TAU,80,Color(.55,.6,.36,.35),1,true)
		for i in range(rows.size()): draw_line(center,center+Vector2.from_angle(-PI*.5+i*TAU/rows.size())*100,Color(.32,.7,.85,.7),2,true)
		draw_circle(center,29,Color("153b4b"))
		draw_arc(center,30,0,TAU,40,Color("bba56b"),2,true)
		var element: String = game.catalog.find_row("heroes",game.character_inspected).element
		draw_texture_rect(game.icons.textures.get(element,game.icons.textures.talents),Rect2(center-Vector2(23,23),Vector2(46,46)),false)
