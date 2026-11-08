class_name DungeonScreen
extends VBoxContainer
## UI only: existing101–103 routes remain model-owned; twelve entries are previews.
const GOLD := Color("e7c676")
const MUTED := Color("a7c5bf")
var game
var world := DungeonWorld.new()
var list_scroll: SwipeScroll
var body: VBoxContainer
var cards: Dictionary = {}
var challenge_button: Button
var difficulty_buttons: Array[Button] = []

func _ready() -> void:
	custom_minimum_size = Vector2(492,720)
	add_theme_constant_override("separation",10)
	header()
	if game.dungeon_selected.is_empty(): listing()
	else:
		var row := world.find(game.dungeon_selected)
		if row.is_empty(): listing()
		else: detail(row)

func words(parent: Node, text: String, font_size: int = 16, color: Color = Color("ecede2")) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size",font_size)
	label.modulate = color
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func picture(parent: Node, texture: Texture2D, minimum: Vector2, cover: bool = true) -> TextureRect:
	var view := TextureRect.new()
	view.texture = texture
	view.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	view.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	view.custom_minimum_size = minimum
	view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(view)
	return view

func frame(parent: Node, highlight: bool = false) -> Frame:
	var panel := Frame.new()
	panel.highlight = highlight
	var style: StyleBoxFlat = game._style(Color(.025,.095,.12,.96),GOLD if highlight else Color("768b82"),16)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	if highlight:
		style.shadow_color = Color(1,.74,.25,.22)
		style.shadow_size = 5
	panel.add_theme_stylebox_override("panel",style)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	return panel

func box(parent: Node, gap: int = 8) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation",gap)
	parent.add_child(column)
	return column

func action(parent: Node, text: String, width: int, callback: Callable, active: bool = false) -> Button:
	var button: Button = game._button(parent,text,Vector2.ZERO,Vector2(width,44),callback)
	button.add_theme_font_size_override("font_size",15)
	button.add_theme_stylebox_override("normal",game._style(Color("423a22") if active else Color("102c37"),GOLD if active else Color("7a9797"),15))
	if active:
		var ornament := Border.new()
		ornament.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		ornament.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(ornament)
	return button

func header() -> void:
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation",8)
	add_child(heading)
	if not game.dungeon_selected.is_empty():
		action(heading,"‹ Back",108,game._dungeon_back)
	var title := words(heading,"DUNGEONS",30,GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size.y = 46
	action(heading,"?",38,game._dungeon_help)

func content_scroll(height: int) -> void:
	list_scroll = SwipeScroll.new()
	list_scroll.name = "DungeonContentScroll"
	list_scroll.custom_minimum_size = Vector2(492,height)
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(list_scroll)
	body = box(list_scroll,12)

func listing() -> void:
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation",4)
	add_child(filters)
	for i in range(DungeonWorld.GROUPS.size()):
		var key: String = DungeonWorld.GROUPS[i]
		var button := action(filters,DungeonWorld.LABELS[i],78,game._dungeon_filter.bind(key),game.dungeon_group == key)
		button.name = "DungeonFilter_"+key
		button.add_theme_font_size_override("font_size",12)
	var overview := HBoxContainer.new()
	add_child(overview)
	words(overview,"15 dungeons · 4 categories",13,MUTED)
	action(overview,"Story chapters ›",144,game._select_tab.bind(5))
	content_scroll(552)
	if game.dungeon_group == "seasonal":
		seasonal()
		return
	for row in world.filtered(game.dungeon_group): card(row)
	list_scroll.set_deferred("scroll_vertical",game.dungeon_list_offset)

func card(row: Dictionary) -> void:
	var panel := frame(body,row.stage > 0)
	panel.name = "DungeonCard_"+row.id
	panel.custom_minimum_size.y = 154
	cards[row.id] = panel
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation",12)
	panel.add_child(line)
	var art := VBoxContainer.new()
	line.add_child(art)
	var thumb := picture(art,DungeonWorld.artwork(row.art),Vector2(140,105))
	thumb.clip_contents = true
	var badge := words(art,"Playable" if row.stage > 0 else "Coming Soon",12,GOLD if row.stage > 0 else MUTED)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var info := box(line,4)
	var title := words(info,row.title,19,GOLD)
	title.custom_minimum_size.x = 280
	words(info,row.summary,13,Color("d0e2d9"))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation",6)
	info.add_child(foot)
	for key in (["gold","cores","xp"] if row.stage > 0 else row.rewards):
		picture(foot,game.icons.textures[key],Vector2(27,27),false)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(spacer)
	var open := action(foot,"View ›",84,game._dungeon_show.bind(row.id),row.stage > 0)
	open.name = "DungeonOpen_"+row.id

func seasonal() -> void:
	var panel := frame(body,true)
	var column := box(panel,12)
	picture(column,DungeonWorld.artwork(13),Vector2(456,185))
	var title := words(column,"Seasonal Journeys",25,GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words(column,"Four seasons, new adventures. Event dungeons will appear here when scheduled.",17)
	words(column,"No event is currently running.",15,MUTED)

func detail(row: Dictionary) -> void:
	content_scroll(644)
	var banner := frame(body,true)
	banner.clip_contents = true
	picture(banner,DungeonWorld.artwork(row.art),Vector2(456,166))
	var title := words(body,row.title,28,GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var group: String = {"resource":"Resources","tactic":"Tactics","boss":"Boss Hunt","endless":"Conquest"}[row.group]
	var subtitle := words(body,group+" · "+("Playable" if row.stage > 0 else "Coming Soon"),14,MUTED)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words(body,row.summary,16)
	if row.group == "endless":
		tower(row)
		return
	difficulties(row)
	var status := frame(body)
	var status_line := HBoxContainer.new()
	status.add_child(status_line)
	var power := words(status_line,"Team Power: %d" % DungeonWorld.team_power(game),15,GOLD)
	power.name = "DungeonTeamPower"
	words(status_line,"Recommended: —",15,MUTED)
	rewards(row)
	enemies(row)
	var rules := frame(body)
	var notes := box(rules,5)
	words(notes,"✦ Dungeon Mechanics",18,GOLD)
	words(notes,row.rules,15)
	if row.stage > 0: live_status(row)
	else: words(body,"Reward attempts and sweeps will arrive with playable stages.",13,MUTED)
	challenge_button = action(body,"BATTLE »" if row.stage > 0 else "PREPARING",474,game._dungeon_enter.bind(row.id),row.stage > 0)
	challenge_button.name = "DungeonChallenge"
	challenge_button.disabled = row.stage == 0 or game._locked() or not game.store.can_enter(row.stage)
	action(body,"Formation & Spirits →",474,game._open_formation)

func difficulties(row: Dictionary) -> void:
	if row.stage > 0:
		var stage: Dictionary = game.catalog.find_row("stages",row.stage)
		words(body,"Current mode · %d waves · No tickets spent" % stage.waves.size(),15,GOLD)
		return
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation",8)
	body.add_child(line)
	for i in range(3):
		var button := action(line,["Easy","Standard","Hard"][i],152,game._dungeon_difficulty.bind(i),game.dungeon_difficulty == i)
		difficulty_buttons.append(button)
	words(body,"Difficulty preview · Stats arrive with playable stages",12,MUTED)

func rewards(row: Dictionary) -> void:
	var panel := frame(body)
	var column := box(panel,8)
	var title := words(column,"✦ Available Rewards" if row.stage > 0 else "✦ Planned Rewards",19,GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation",8)
	column.add_child(grid)
	if row.stage > 0:
		var stage: Dictionary = game.catalog.find_row("stages",row.stage)
		for reward in [["gold","Gold",str(stage.gold)],["cores","Cores",str(stage.cores)],["xp","XP",str(stage.xp)],["shards","Crystals","2"],["equipment","Equipment","Random"]]:
			reward_tile(grid,reward[0],reward[1],reward[2])
		for id in Supplies.DROPS.get(int(row.stage),{}):
			var line := HBoxContainer.new()
			column.add_child(line)
			picture(line,Supplies.icon(id),Vector2(34,34),false)
			words(line,"+%d %s" % [Supplies.DROPS[int(row.stage)][id],Supplies.NAMES[id]],14,GOLD)
	else:
		for key in row.rewards: reward_tile(grid,key,{"shards":"Crystals","gold":"Gold","xp":"XP","cores":"Spirit Cores","spirit":"Spirit Fragments","training_item":"Upgrade Materials","forge":"Forge Materials","chest":"Treasure","achievement":"Milestone Rewards"}[key],"—")

func reward_tile(parent: Node, key: String, caption: String, amount: String) -> void:
	var column := box(parent,3)
	column.custom_minimum_size.x = 80
	picture(column,game.icons.textures[key],Vector2(55,55),false)
	var label := words(column,caption,12,Color("e4ddbf"))
	label.custom_minimum_size.x = 80
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var value := words(column,amount,13,GOLD)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func enemies(row: Dictionary) -> void:
	var panel := frame(body)
	var column := box(panel,8)
	var label := words(column,"✦ Enemies" if row.stage > 0 else "✦ Planned Enemies",19,GOLD)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	column.add_child(grid)
	for entry in row.enemies:
		var cell := frame(grid)
		cell.custom_minimum_size.x = 140
		var content := box(cell,3)
		var texture: Texture2D = game.frames.textures[entry[1]] if entry[1] is String else DungeonWorld.artwork(int(entry[1]),true)
		picture(content,texture,Vector2(120,100),not entry[1] is String)
		var name_label := words(content,entry[0],12,Color("eee5ce"))
		name_label.custom_minimum_size.x = 120
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func live_status(row: Dictionary) -> void:
	var stage: Dictionary = game.catalog.find_row("stages",row.stage)
	if not game.store.can_enter(row.stage):
		var needed: int = stage.requires[0]
		words(body,"Unlocks after completing "+game.catalog.find_row("stages",needed).name,14,GOLD)
	var record: Dictionary = game.store.profile.expansion.records.get(str(row.stage),{})
	if record.is_empty(): words(body,"No record yet · Rewards on victory",13,MUTED)
	else: words(body,"Best: %d points · %.1f seconds" % [record.score,record.time],14,GOLD)
	words(body,"Sweeps will be added later.",13,MUTED)

func tower(row: Dictionary) -> void:
	var status := frame(body,true)
	var column := box(status)
	words(column,"Current floor: — / 100",21,GOLD)
	words(column,"Team Power: %d" % DungeonWorld.team_power(game),15)
	words(column,"100 floors planned · May expand to 500 floors",14,MUTED)
	var milestones := frame(body)
	var content := box(milestones,8)
	words(content,"✦ Conquest Milestones",20,GOLD)
	for entry in [["5","Elite","boss"],["10","Boss · Changing mechanics","achievement"],["20","Boss · Changing mechanics","achievement"]]:
		var line := HBoxContainer.new()
		line.add_theme_constant_override("separation",12)
		content.add_child(line)
		picture(line,game.icons.textures[entry[2]],Vector2(36,36),false)
		words(line,"Floor "+entry[0]+" · "+entry[1],16)
	rewards(row)
	enemies(row)
	var rules := frame(body)
	var notes := box(rules)
	words(notes,"✦ Tower Rules",20,GOLD)
	words(notes,"Each floor has first-clear rewards. Elites appear every 5 floors and bosses every 10. Enemy mechanics change after every 10 floors.",15)
	words(notes,"Reward milestones and floor enemies will arrive with this mode.",13,MUTED)
	challenge_button = action(body,"TOWER COMING SOON",474,game._dungeon_enter.bind(row.id),true)
	challenge_button.name = "DungeonChallenge"
	challenge_button.disabled = true
	var ranks := action(body,"Rankings · Coming soon",474,game._dungeon_help)
	ranks.disabled = true

class Frame extends PanelContainer:
	var highlight := false
	func _draw() -> void:
		var tint := Color("e7c676") if highlight else Color("9aa780")
		for corner in [Vector2(6,6),Vector2(size.x-6,6),Vector2(6,size.y-6),Vector2(size.x-6,size.y-6)]:
			var direction := Vector2(1 if corner.x<size.x/2 else -1,1 if corner.y<size.y/2 else -1)
			draw_polyline(PackedVector2Array([corner+Vector2(0,15*direction.y),corner,corner+Vector2(15*direction.x,0)]),tint,1,true)
			var point: Vector2 = corner+direction*5
			draw_polyline(PackedVector2Array([corner,point+Vector2(6*direction.x,0),point,point+Vector2(0,6*direction.y),corner]),Color(tint,.65),1,true)

class Border extends Control:
	func _draw() -> void:
		var c := size/2
		for x in [7.0,size.x-7]:
			var center := Vector2(x,c.y)
			draw_polyline(PackedVector2Array([center+Vector2(0,-8),center+Vector2(4,0),center+Vector2(0,8),center+Vector2(-4,0),center+Vector2(0,-8)]),Color("f6d98a"),1.2,true)
