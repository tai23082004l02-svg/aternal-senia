class_name BagScreen
extends VBoxContainer

var game
var body: VBoxContainer

func words(parent: Node, value: String, size: int = 16, tint: Color = Color("d9dfd6")) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.modulate = tint
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label

func picture(parent: Node, texture: Texture2D, dimension: Vector2) -> TextureRect:
	var image := TextureRect.new()
	image.texture = texture
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	image.custom_minimum_size = dimension
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(image)
	return image

func scene_texture(index: int) -> AtlasTexture:
	var texture := AtlasTexture.new()
	texture.atlas = load("res://art/bag/scenes.png")
	texture.region = Rect2(0,index*512,1536,512)
	texture.filter_clip = true
	return texture

func _ready() -> void:
	custom_minimum_size = Vector2(492,720)
	add_theme_constant_override("separation", 10)
	var heading := HBoxContainer.new()
	add_child(heading)
	words(heading,"FORGE" if game.tab == 19 else "BAG",30,Color("edcf85"))
	game._button(heading,"?",Vector2.ZERO,Vector2(38,38),game._bag_help)
	if game.tab == 19:
		forge()
		return
	if game.bag_section == "":
		home()
		return
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation",6)
	add_child(tabs)
	for pair in [["equipment","Equipment"],["spirits","Spirit"],["materials","Materials"],["supplies","Items"]]:
		var button: Button = game._button(tabs,pair[1],Vector2.ZERO,Vector2(118,44),game._bag_open.bind(pair[0]))
		button.add_theme_font_size_override("font_size",14)
		if game.bag_section == pair[0]: button.add_theme_stylebox_override("normal",game._style(Color("493f24"),Color("f3cd76"),12))
	var scroll := SwipeScroll.new()
	scroll.name = "BagContentScroll"
	scroll.custom_minimum_size = Vector2(492,490)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",10)
	scroll.add_child(body)
	match game.bag_section:
		"equipment":
			var previous: VBoxContainer = game.panel
			game.panel = body
			game._equipment_inventory()
			game.panel = previous
		"spirits": spirits()
		"materials": materials()
		"supplies":
			var screen := SuppliesScreen.new()
			screen.game = game
			body.add_child(screen)
	var footer := HBoxContainer.new()
	add_child(footer)
	words(footer,("Equipment: %d / 40" if game.bag_section == "supplies" else "Quantity: %d / 40") % game.store.profile.items.size(),16,Color("e8d8ae"))
	if game.bag_section == "equipment":
		if game.bag_selecting:
			game._button(footer,"Cancel",Vector2.ZERO,Vector2(70,44),game._bag_select_mode)
			game._button(footer,"Dismantle %d" % game.bag_selected.size(),Vector2.ZERO,Vector2(112,44),game._bag_dismantle_confirm).disabled = game._locked() or game.bag_selected.is_empty()
		else: game._button(footer,"♻ Dismantle",Vector2.ZERO,Vector2(150,44),game._bag_select_mode).disabled = game._locked()
	else: game._button(footer,"← Overview",Vector2.ZERO,Vector2(150,44),game._bag_open.bind(""))
	if not game.store.profile.bag_rewards.is_empty():
		game._button(self,"Unclaimed loot: %d →" % game.store.profile.bag_rewards.size(),Vector2.ZERO,Vector2(492,40),game._bag_claim_loot).disabled = game._locked() or game.store.profile.items.size() >= 40

func home() -> void:
	words(self,"Manage your equipment, spirits, and materials.",16,Color("b8cdc7"))
	var types := {}
	for item in game.store.profile.items: types[item.base] = true
	var owned := 0
	for row in game.catalog.data.assists:
		if game.store.available_assist(row.id): owned += 1
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",12)
	grid.add_theme_constant_override("v_separation",12)
	add_child(grid)
	for entry in [
		["equipment","Equipment","%d types · %d items" % [types.size(),game.store.profile.items.size()],"equipment"],
		["companion","Spirit","%d / %d unlocked" % [owned,game.catalog.data.assists.size()],"spirits"],
		["crystal","Materials","Crystals · Cores · Fragments","materials"],
		["forge","Forge","Craft · Enhance","forge"]]:
		var button: Button = game._button(grid,"",Vector2.ZERO,Vector2(240,210),game._select_tab.bind(19) if entry[3] == "forge" else game._bag_open.bind(entry[3]))
		button.name = "BagCategory_"+entry[3]
		var color := Color("b880dd") if entry[3] == "materials" else Color("e9bf65")
		button.add_theme_stylebox_override("normal",game._style(Color(.035,.1,.13,.95),color,22))
		var flourish := Flourish.new()
		flourish.tint = color
		flourish.size = Vector2(240,210)
		flourish.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(flourish)
		var icon := picture(button,game.icons.textures[entry[0]],Vector2.ZERO)
		icon.position = Vector2(65,14)
		icon.size = Vector2(110,110)
		var title: Label = game._label(button,entry[1],Vector2(0,132),25,color)
		title.size.x = 240
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var caption: Label = game._label(button,entry[2],Vector2(8,173),14,Color("e6dfcb"))
		caption.size.x = 224
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	game._button(self,"Items · Potions, tickets & materials →",Vector2.ZERO,Vector2(492,44),game._supply_open.bind(""))
	picture(self,scene_texture(0),Vector2(492,164))
	if not game.store.profile.bag_rewards.is_empty():
		game._button(self,"Claim pending loot (%d)" % game.store.profile.bag_rewards.size(),Vector2.ZERO,Vector2(492,40),game._bag_claim_loot).disabled = game._locked() or game.store.profile.items.size() >= 40

func spirits() -> void:
	words(body,"Upgrade and choose a spirit to accompany your team.",14,Color("a9c4bc"))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",12)
	body.add_child(grid)
	for row in game.catalog.data.assists:
		var column := VBoxContainer.new()
		column.custom_minimum_size.x = 240
		grid.add_child(column)
		var button: Button = game._button(column,"",Vector2.ZERO,Vector2(240,210),game._bag_spirit_select.bind(row.id))
		button.add_theme_stylebox_override("normal",game._style(Color("102a36"),Color("e1bd67") if row.id == game.selected_spirit else Color("526a70"),20))
		var image := picture(button,game.frames.textures["companion_"+row.id],Vector2.ZERO)
		image.position = Vector2(40,10)
		image.size = Vector2(160,145)
		var name_label: Label = game._label(button,row.name+" · "+row.rarity,Vector2(0,156),20,Color("ead49f"))
		name_label.size.x = 240
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var state: Label = game._label(button,"Accompanying" if game.store.profile.assist == row.id else ("Usable" if game.store.available_assist(row.id) else "Locked"),Vector2(0,184),13)
		state.size.x = 240
		state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var id: String = game.selected_spirit if not game.selected_spirit.is_empty() else game.store.profile.assist
	var row: Dictionary = game.catalog.find_row("assists",id)
	words(body,"✦ Spirit Details · "+row.name,22,Color("ead49f"))
	words(body,"LV %d/20 · Evolution %d/3" % [game.store.profile.assists[id],game.store.profile.expansion.ranks[id]],17)
	words(body,"Heal and shield surviving allies." if id == "lumi" else "The fire phoenix damages multiple targets and helps break shields.",16,Color("b6cdc5"))
	words(body,"%s Fragments: %d" % [row.name,game.store.profile.collection_fragments.spirits[id]],15)
	var actions := HBoxContainer.new()
	body.add_child(actions)
	game._button(actions,"Upgrade · %d Gold" % (game.store.profile.assists[id]*35),Vector2.ZERO,Vector2(244,48),game._bag_upgrade_spirit.bind(id)).disabled = game._locked() or not game.store.available_assist(id) or game.store.profile.assists[id] >= 20 or game.store.profile.gold < game.store.profile.assists[id]*35
	game._button(actions,"Accompanying" if game.store.profile.assist == id else "Choose companion",Vector2.ZERO,Vector2(244,48),game._assist.bind(id)).disabled = game._locked() or not game.store.available_assist(id) or game.store.profile.assist == id
	game._button(body,"Skills & evolution details →",Vector2.ZERO,Vector2(492,44),game._open_spirit.bind(id))

func materials() -> void:
	words(body,"Available materials · Tap for details.",14,Color("abc5bc"))
	var p: Dictionary = game.store.profile
	var hero_total := 0
	var spirit_total := 0
	var item_total := 0
	for count in Recruitment.state(p).fragments.values(): hero_total += int(count)
	for count in p.collection_fragments.spirits.values(): spirit_total += int(count)
	for count in p.collection_fragments.items.values(): item_total += int(count)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",6)
	grid.add_theme_constant_override("v_separation",8)
	body.add_child(grid)
	for entry in [["gold","Gold",p.gold],["shards","Crystals",p.shards],["xp","XP",p.xp],["cores","Spirit Cores",p.expansion.cores],["fragments","Hero Fragments",hero_total],["spirit","Spirit Fragments",spirit_total],["weapon_category","Equipment Fragments",item_total]]:
		var card: Button = game._button(grid,"",Vector2.ZERO,Vector2(158,164),game._bag_material_detail.bind(entry[0]))
		card.add_theme_stylebox_override("normal",game._style(Color("102735"),Color("69888c"),16))
		var icon := picture(card,game.icons.textures[entry[0]],Vector2.ZERO)
		icon.position = Vector2(39,8)
		icon.size = Vector2(80,80)
		var title: Label = game._label(card,entry[1],Vector2(5,91),15,Color("e5d8ad"))
		title.size = Vector2(148,35)
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var count: Label = game._label(card,str(entry[2]),Vector2(5,132),20)
		count.size.x = 148
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count.mouse_filter = Control.MOUSE_FILTER_IGNORE
	words(body,"Legacy Equipment Fragments are preserved. New equipment enters your bag as individual copies.",14,Color("a9c4bc"))
	game._button(body,"⚒ Go to Forge · Craft & Upgrade",Vector2.ZERO,Vector2(492,48),game._select_tab.bind(19))

func forge() -> void:
	words(self,"Craft, enhance, and develop equipment.",16,Color("adc4bc"))
	picture(self,scene_texture(1),Vector2(492,164))
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation",4)
	add_child(tabs)
	for i in range(4):
		var button: Button = game._button(tabs,["Craft","Enhance","Fuse","Dismantle"][i],Vector2.ZERO,Vector2(120,44),game._forge_tab.bind(i))
		button.add_theme_font_size_override("font_size",14)
		if game.forge_page == i: button.modulate = Color("f6cf7a")
	var scroll := SwipeScroll.new()
	scroll.custom_minimum_size = Vector2(492,330)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(body)
	if game.forge_page == 0:
		words(body,"65 Gold + 3 Crystals per item · Each copy has its own upgrades.",14)
		var quantity := SpinBox.new()
		quantity.name = "ForgeQuantity"
		quantity.min_value = 1
		quantity.max_value = 10
		quantity.value = game.forge_count
		quantity.prefix = "Quantity: "
		quantity.custom_minimum_size = Vector2(492,44)
		quantity.value_changed.connect(func(value): game.forge_count = int(value))
		body.add_child(quantity)
		for row in game.catalog.data.items:
			if row.get("summon_only",false): continue
			var button: Button = game._button(body,"Forge · "+row.name,Vector2.ZERO,Vector2(492,44),game._forge_batch_confirm.bind(row.id))
			game.icons.apply(button,row.id,32)
			button.disabled = game._locked()
	else:
		words(body,["","Select the exact equipment copy to enhance.","Keep one copy and consume two +0 copies of the same item and rank to gain one rank. Equipped items cannot be consumed.","Choose equipment from your bag to dismantle. Equipped items are protected."][game.forge_page],15)
		for item in game.store.profile.items:
			var row: Dictionary = game.catalog.find_row("items",item.base)
			var button: Button = game._button(body,row.name+" +%d · Rank %d · %s" % [item.enhance,item.rank,item.uid],Vector2.ZERO,Vector2(492,44),game._forge_fuse_confirm.bind(item.uid) if game.forge_page == 2 else game._item_detail.bind(item.uid))
			game.icons.apply(button,row.id,30)
			if game.forge_page == 2: button.disabled = game._locked() or game.store.fusion_donors(item.uid).size() != 2
	game._button(self,"← Bag",Vector2.ZERO,Vector2(492,44),game._bag_open.bind(""))

class Flourish extends Control:
	var tint := Color("e9bf65")
	func _draw() -> void:
		var faint := Color(tint,.2)
		draw_arc(Vector2(size.x/2,79),69,0,TAU,64,faint,1,true)
		for corner in [Vector2(14,14),Vector2(size.x-14,14),Vector2(14,size.y-14),Vector2(size.x-14,size.y-14)]:
			var direction := Vector2(1 if corner.x < size.x/2 else -1,1 if corner.y < size.y/2 else -1)
			draw_polyline(PackedVector2Array([corner+Vector2(0,25*direction.y),corner,corner+Vector2(25*direction.x,0)]),tint,1.4,true)
			var leaf: Vector2 = corner+direction*7
			draw_polyline(PackedVector2Array([corner,leaf+Vector2(11*direction.x,0),leaf,leaf+Vector2(0,11*direction.y),corner]),Color(tint,.65),1,true)
		var center := Vector2(size.x/2,3)
		draw_colored_polygon(PackedVector2Array([center+Vector2(0,-3),center+Vector2(7,5),center+Vector2(0,13),center+Vector2(-7,5)]),tint)
