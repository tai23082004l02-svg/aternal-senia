class_name CharacterPanelPage
extends Control

var game
var hero := "eira"
var equipment_page := false
var lower: VBoxContainer
var title_box: VBoxContainer
var name_plate: Control
var slot_buttons: Array[Button] = []

func _ready() -> void:
	custom_minimum_size = Vector2(416,642)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var art := HeroBanner.new()
	art.name = "CharacterArtwork"
	art.hero = hero
	art.library = game.frames
	art.panel_art = true
	art.panel_info = not equipment_page
	art.interactive = game.store.available_hero(hero) and Recruitment.rarity("hero",hero,game.catalog) == 5
	art.palette_tint = Wardrobe.tint(game.store.profile,hero)
	add_child(art)
	art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var help: Button = game._button(self,"?",Vector2(370,12),Vector2(32,32),game._character_help)
	help.tooltip_text = tr("Hero Help")
	if not equipment_page:
		name_plate = NamePlate.new()
		name_plate.position = Vector2(6,286)
		name_plate.size = Vector2(404,105)
		name_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(name_plate)
	title_box = VBoxContainer.new()
	title_box.position = Vector2(24,14 if equipment_page else 305)
	title_box.size.x = 368
	title_box.add_theme_constant_override("separation",1)
	add_child(title_box)
	var row: Dictionary = game.catalog.find_row("heroes",hero)
	center_label(title_box,tr(row.name),28,Color("f2d38b"))
	center_label(title_box,tr(row.title),13,Color("f2e9d5"))
	center_label(title_box,"★".repeat(Recruitment.rarity("hero",hero,game.catalog)),19,Color("ffc665"))
	lower = VBoxContainer.new()
	lower.position = Vector2(18,420 if equipment_page else 390)
	lower.size.x = 380
	lower.add_theme_constant_override("separation",7)
	add_child(lower)
	if equipment_page: equipment()
	else: info()
	if not game.store.available_hero(hero):
		label(lower,tr("Not owned"),13,Color("f1cf91"))
		action(tr("Go to Shop →"),game._select_tab.bind(20))
	lower.resized.connect(_fit_content)
	title_box.resized.connect(_fit_content)
	call_deferred("_fit_content")

func _fit_content() -> void:
	if not equipment_page: lower.position.y = maxf(390,title_box.position.y+title_box.size.y+8)
	elif slot_buttons.size() == 4:
		var top := maxf(125,title_box.position.y+title_box.size.y+10)
		var first_height := 126.0
		var second_height := 126.0
		for i in range(4):
			var card := slot_buttons[i]
			card.size.y = maxf(126,card.get_child(0).get_combined_minimum_size().y+10)
			if i < 2: first_height = maxf(first_height,card.size.y)
			else: second_height = maxf(second_height,card.size.y)
		for i in range(4): slot_buttons[i].position.y = top if i < 2 else top+first_height+18
		lower.position.y = maxf(420,top+first_height+18+second_height+18)
	if name_plate != null:
		name_plate.size.y = maxf(105,lower.position.y-name_plate.position.y)
		name_plate.queue_redraw()
	custom_minimum_size.y = maxf(642,lower.position.y+lower.get_combined_minimum_size().y+18)

func label(parent: Node,value: String, font_size: int = 13, color: Color = Color("d6e1db")) -> Label:
	var result := Label.new()
	result.text = value
	result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result.add_theme_font_size_override("font_size",font_size)
	result.add_theme_color_override("font_color",color)
	parent.add_child(result)
	return result

func center_label(parent: Node,value: String,font_size: int,color: Color) -> Label:
	var result := label(parent,value,font_size,color)
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return result

func panel(parent: Node,active: bool = false) -> PanelContainer:
	var box := PanelContainer.new()
	var style: StyleBoxFlat = game._style(Color(.025,.12,.15,.94),Color("c6a666"),12)
	style.set_content_margin_all(5)
	if active:
		style.bg_color = Color(.04,.18,.20,.97)
		style.shadow_color = Color(1,.65,.17,.25)
		style.shadow_size = 5
	box.add_theme_stylebox_override("panel",style)
	parent.add_child(box)
	return box

func action(value: String,callback: Callable) -> Button:
	var button: Button = game._button(lower,value,Vector2.ZERO,Vector2(380,42),callback)
	var style: StyleBoxFlat = game._style(Color("423921"),Color("e3c17c"),15)
	style.shadow_color = Color(1,.65,.17,.2)
	style.shadow_size = 4
	button.add_theme_stylebox_override("normal",style)
	button.add_theme_font_size_override("font_size",15)
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var ornament := ButtonOrnament.new()
	ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(ornament)
	ornament.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return button

func info() -> void:
	var p: Dictionary = game.store.profile
	var stats: Dictionary = game.catalog.stats(p,hero)
	var power := panel(lower,true)
	center_label(power,tr("✦ Estimated Power %d") % int(stats.hp+stats.atk*10+stats.defense*6),16,Color("f7d791"))
	var chips := HBoxContainer.new()
	chips.add_theme_constant_override("separation",5)
	lower.add_child(chips)
	for value in [tr("LV %d/100") % p.heroes[hero].level,tr("Evolution %d/3") % HeroEvolution.rank(p,hero),tr("Awakening %d/5") % Recruitment.state(p).awakening[hero]]:
		var box := panel(chips)
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center_label(box,value,10,Color("e8d8ae"))
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation",5)
	lower.add_child(grid)
	for pair in [[tr("HP"),str(int(stats.hp)),"heal"],[tr("ATK"),str(int(stats.atk)),"slash"],[tr("DEF"),str(snappedf(stats.defense,.01)),"guard"],[tr("Critical"),"%d%%" % (stats.crit*100),"talents"]]:
		var box := panel(grid)
		box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation",1)
		box.add_child(col)
		var image := TextureRect.new()
		image.texture = game.icons.textures[pair[2]]
		image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image.custom_minimum_size = Vector2(20,20)
		col.add_child(image)
		center_label(col,pair[0],10,Color("f2e5c6"))
		center_label(col,pair[1],16,Color("fff4d8"))
	var passive := panel(lower)
	var content := VBoxContainer.new()
	passive.add_child(content)
	label(content,tr("TRAITS"),12,Color("efc677"))
	label(content,tr(game.catalog.find_row("heroes",hero).passive),12)
	action(tr("Assign to Formation →"),game._select_tab.bind(22))
	if hero == "ryn": action(tr("View Ryn portrait →"),game._show_ryn_portrait)
	if p.hero == hero: action(tr("Attribute Points →"),game._select_tab.bind(9))

func equipment() -> void:
	var p: Dictionary = game.store.profile
	for i in range(EquipmentSystem.SLOTS.size()):
		var slot_name: String = EquipmentSystem.SLOTS[i]
		var item := EquipmentSystem.item_for(p,p.heroes[hero].equipment[slot_name])
		var callback: Callable = game._character_gear_picker.bind(hero,slot_name) if item.is_empty() else game._character_item_detail.bind(item.uid,hero)
		var card: Button = game._button(self,"",Vector2(12 if i%2 == 0 else 310,125 if i < 2 else 272),Vector2(94,126),callback)
		card.name = "EquipmentSlot_"+slot_name
		var style: StyleBoxFlat = game._style(Color(.025,.12,.15,.95),Color("d9b566"),14)
		if not item.is_empty():
			style.shadow_color = Color(1,.7,.18,.2)
			style.shadow_size = 4
		card.add_theme_stylebox_override("normal",style)
		slot_buttons.append(card)
		var content := VBoxContainer.new()
		content.position = Vector2(6,5)
		content.size.x = 82
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_theme_constant_override("separation",3)
		card.add_child(content)
		center_label(content,tr(EquipmentSystem.SLOT_NAMES[slot_name]),12,Color("f2dfae"))
		var icon_holder := Control.new()
		icon_holder.custom_minimum_size = Vector2(68,68)
		icon_holder.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		icon_holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(icon_holder)
		if item.is_empty():
			var plus: Label = game._label(icon_holder,"+",Vector2(0,10),34,Color("e4be6b"))
			plus.size.x = 68
			plus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			plus.mouse_filter = Control.MOUSE_FILTER_IGNORE
		else:
			var row: Dictionary = game.catalog.find_row("items",item.base)
			EquipmentArt.add_to(icon_holder,game,item.base,row.rarity,68)
		center_label(content,tr("Not equipped") if item.is_empty() else tr("Rank %d · +%d") % [item.rank,item.enhance],11,Color("eee1c2"))
		content.minimum_size_changed.connect(_fit_content)
	var counts := EquipmentSystem.set_counts(game.catalog,p,hero)
	for definition in game.catalog.data.sets:
		if not counts.has(definition.id): continue
		var box := panel(lower)
		var text_col := VBoxContainer.new()
		box.add_child(text_col)
		label(text_col,tr("SET %s · %d/4") % [tr(definition.name).to_upper(),counts[definition.id]],17,Color("f2ce85"))
		for bonus in definition.bonuses:
			label(text_col,("◆ " if counts[definition.id] >= bonus.pieces else "◇ ")+tr("%d pieces: %s") % [bonus.pieces,tr(bonus.description)],12)
	if counts.is_empty(): label(lower,tr("No equipment set active."),13)
	center_label(lower,tr("Tap an item to inspect stats and enhance it; tap an empty slot to choose equipment."),12,Color("eee6d0"))
	action(tr("Open equipment bag →"),game._bag_open.bind("equipment"))

class NamePlate extends Control:
	func _draw() -> void:
		var edge := PackedVector2Array()
		for i in range(41):
			var t := i/40.0
			edge.append(Vector2(t*size.x,14+34*pow(absf(t*2-1),1.5)))
		var polygon := edge.duplicate()
		polygon.append(Vector2(size.x,size.y))
		polygon.append(Vector2(0,size.y))
		draw_colored_polygon(polygon,Color(.025,.12,.15,.96))
		draw_polyline(edge,Color("d1ad61"),1.5,true)
		var c := Vector2(size.x*.5,14)
		draw_colored_polygon(PackedVector2Array([c+Vector2(0,-10),c+Vector2(4,0),c+Vector2(0,10),c+Vector2(-4,0)]),Color("f8da8b"))

class ButtonOrnament extends Control:
	func _draw() -> void:
		for x in [9.0,size.x-9]:
			var c := Vector2(x,size.y*.5)
			draw_polyline(PackedVector2Array([c+Vector2(0,-7),c+Vector2(4,0),c+Vector2(0,7),c+Vector2(-4,0),c+Vector2(0,-7)]),Color("e4c27b"),1,true)
