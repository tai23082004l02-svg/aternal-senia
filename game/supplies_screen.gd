class_name SuppliesScreen
extends VBoxContainer
const GOLD := Color("ebce88")
var game

func words(parent: Node, text: String, font_size: int = 15, tint: Color = Color("d6e4db")) -> Label:
	var label := Label.new()
	label.text = tr(text)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size",font_size)
	label.modulate = tint
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func button(parent: Node, text: String, call: Callable, disabled: bool = false) -> Button:
	var action: Button = game._button(parent,tr(text),Vector2.ZERO,Vector2(458,44),call)
	action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action.add_theme_font_size_override("font_size",14)
	action.disabled = disabled
	return action

func _ready() -> void:
	custom_minimum_size.x = 464
	add_theme_constant_override("separation",10)
	if game.supply_selected not in Supplies.ORDER:
		listing()
		return
	detail(game.supply_selected)

func listing() -> void:
	words(self,"ESSENTIAL ITEMS",22,GOLD)
	words(self,"Separate stacks · No equipment slots used",13)
	button(self,"Progress Gifts · View requirements →",game._supply_milestones)
	var selected: String = game.store.profile.supplies.selected
	if selected!="": words(self,"Prepared: "+Supplies.NAMES[selected]+" · Consumed at the start of one run",14,GOLD)
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation",5)
	add_child(filters)
	for pair in [["all","All"],["consumable","Consumables"],["upgrade","Upgrade"],["spirit","Spirit"],["ticket","Tickets / Chests"]]:
		var action: Button = game._button(filters,pair[1],Vector2.ZERO,Vector2(88,44),game._supply_filter.bind(pair[0]))
		action.clip_text = true
		action.add_theme_font_size_override("font_size",12)
		if game.supply_group==pair[0]: action.modulate = GOLD
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation",10)
	grid.add_theme_constant_override("v_separation",10)
	add_child(grid)
	for id in Supplies.ORDER:
		if game.supply_group!="all" and Supplies.GROUPS[id]!=game.supply_group: continue
		var card: Button = game._button(grid,"",Vector2.ZERO,Vector2(224,184),game._supply_open.bind(id))
		card.name = "Supply_"+id
		card.add_theme_stylebox_override("normal",game._style(Color("102a35"),GOLD if Supplies.count(game.store.profile,id)>0 else Color("647b78"),18))
		var art := TextureRect.new()
		art.texture = Supplies.icon(id)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.position = Vector2(56,0)
		art.size = Vector2(112,112)
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(art)
		var title: Label = game._label(card,Supplies.NAMES[id],Vector2(8,116),14,GOLD)
		title.size = Vector2(208,40)
		title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var count: Label = game._label(card,"×%d" % Supplies.count(game.store.profile,id),Vector2(8,160),18)
		count.size.x = 208
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count.mouse_filter = Control.MOUSE_FILTER_IGNORE

func detail(id: String) -> void:
	button(self,"‹ Item List",game._supply_open.bind(""))
	var art := TextureRect.new()
	art.texture = Supplies.icon(id)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.custom_minimum_size = Vector2(458,146)
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(art)
	var title := words(self,Supplies.NAMES[id],24,GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	words(self,"Available: %d" % Supplies.count(game.store.profile,id),19,GOLD)
	words(self,{"forge_stone":"Enhance by one level using one Stone and the current Gold cost instead of one Crystal. Rank-up costs remain unchanged.",
	"memory_shard":"Upgrade either of two hero skills by one level using Shards equal to its current level. No Gold cost; max LV 10. Gold upgrades remain available.",
	"ancient_seed":"Refine 3 Seeds into 1 Spirit Core for the existing evolution system.",
	"normal_ticket":"One ticket grants one Standard summon using the existing pool and pity rules. No Gold consumed. A full bag or failed save will not consume tickets.",
	"material_chest":"Open one chest and choose one reward: 3 Radiant Forge Stones, 2 Memory Shards, or 3 Ancient Tree Seeds. No random rewards.",
	"rage_potion":"Pre-battle: +10% team ATK for one run. Select one potion only. Consumed at the start, even on defeat; resuming does not consume another.",
	"ward_potion":"Pre-battle: +10% team DEF for one run. Select one potion only. Consumed at the start, even on defeat; resuming does not consume another.",
	"afk_hourglass":"Instantly receive 2 hours of AFK Gold based on your current Journey progress. Preserves accumulated AFK time; AFK currently grants Gold only."}[id],15)
	var busy := Supplies.busy(game.store)
	var owned := Supplies.count(game.store.profile,id)
	match id:
		"forge_stone":
			words(self,"Choose an equipment copy · UID and rank preserved",16,GOLD)
			for item in game.store.profile.items:
				var row: Dictionary = game.catalog.find_row("items",item.base)
				button(self,"%s +%d · %s\n%d Gold + 1 Stone" % [row.name,item.enhance,item.uid,(item.enhance+1)*20],game._supply_confirm.bind("stone",item.uid,0),busy or owned<1 or item.enhance>=15 or game.store.profile.gold<(item.enhance+1)*20)
		"memory_shard":
			var hero: String = game.supply_hero if not game.supply_hero.is_empty() else game.store.profile.hero
			var heroes := HBoxContainer.new()
			add_child(heroes)
			for row in game.catalog.data.heroes:
				var select: Button = game._button(heroes,row.name,Vector2.ZERO,Vector2(110,44),game._supply_hero.bind(row.id))
				select.disabled = not game.store.available_hero(row.id)
				if hero==row.id: select.modulate = GOLD
			for i in range(2):
				var level: int = game.store.profile.heroes[hero].skills[i]
				button(self,"%s · Skill %d · LV %d/10\nUpgrade 1 level · %d Shards" % [game.catalog.find_row("heroes",hero).name,i+1,level,level],game._supply_confirm.bind("train",hero,i),busy or level>=10 or owned<level or not game.store.available_hero(hero))
		"ancient_seed":
			button(self,"Refine 3 Seeds → 1 Spirit Core",game._supply_confirm.bind("seed","",0),busy or owned<3)
		"material_chest":
			for choice in Supplies.CHEST:
				button(self,"Choose %d × %s" % [Supplies.CHEST[choice],Supplies.NAMES[choice]],game._supply_confirm.bind("chest",choice,0),busy or owned<1)
		"normal_ticket":
			for amount in [1,10]:
				button(self,"Summon ×%d · %d Tickets · No Gold spent" % [amount,amount],game._supply_confirm.bind("ticket","",amount),busy or owned<amount)
		"rage_potion","ward_potion":
			button(self,"Prepared" if game.store.profile.supplies.selected==id else "Prepare for one run",game._supply_confirm.bind("select",id,0),busy or owned<1 or game.store.profile.supplies.selected==id)
			if not game.store.profile.supplies.selected.is_empty(): button(self,"Clear prepared item · Keep potion",game._supply_confirm.bind("select","",0),busy)
			button(self,"Buy 1 · %d Gold" % Supplies.SHOP[id],game._supply_confirm.bind("buy",id,0),busy or game.store.profile.gold<Supplies.SHOP[id])
		"afk_hourglass":
			button(self,"Use 1 Hourglass · +%d Gold" % game.store.offline_amount(7200),game._supply_confirm.bind("hourglass","",0),busy or owned<1)
	words(self,"✦ Sources",18,GOLD)
	match id:
		"forge_stone":
			words(self,"Clear Dawn Triad: 2 Stones per run. Also available in Choice Chests. The Ancient Forge will offer another source later.",14)
			button(self,"Go to Dawn Triad →",game._supply_source.bind("dawn_wardens"))
		"memory_shard":
			words(self,"Clear Six-Wave Tower: 2 Shards per run. Also available in Choice Chests.",14)
			button(self,"Go to Six-Wave Tower →",game._supply_source.bind("six_waves"))
		"ancient_seed":
			words(self,"Clear Elder Tree Grove: 1 Seed per run. Also available in Choice Chests.",14)
			button(self,"Go to Elder Tree Grove →",game._supply_source.bind("grove"))
		"material_chest","normal_ticket","afk_hourglass":
			words(self,"One-time progress gifts after clearing stages 1/2/3: a chest, ticket, and hourglass respectively. Previous clears remain eligible if these gifts have not been claimed.",14)
			button(self,"View Progress Gifts →",game._supply_milestones)
		_:
			words(self,"Available in the Gold Shop · 60 Gold each.",14)
