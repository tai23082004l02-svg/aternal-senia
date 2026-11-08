class_name HomeScreen
extends Control
## Session portrait selection does not write profile, formation or ownership.
var game
var actions: Dictionary = {}
var hero_id := ""

func _ready() -> void:
	custom_minimum_size = Vector2(492, 732)
	hero_id = game.home_hero
	if hero_id.is_empty(): hero_id = "selena_preview"
	var row: Dictionary = CharacterPreviews.find(hero_id)
	if row.is_empty():
		if not game.store.available_hero(hero_id): hero_id = PlayerIdentity.state(game.store.profile).avatar
		if not game.store.available_hero(hero_id): hero_id = game.store.profile.hero
		row = game.catalog.find_row("heroes", hero_id)
	var image := UIDesignV2.art(self, load(row.art.banner), Vector2(-24,0), Vector2(540,732))
	image.focus = Vector2(.5,.08)
	UIDesignV2.shade(self,Vector2(-24,-132),Vector2(540,260),Color("0b143088"),Color("0b143000"))
	UIDesignV2.shade(self,Vector2(-24,320),Vector2(540,412),Color("0b143000"),Color("080f29fa"))
	link("missions", "Missions", Vector2(0,24), Vector2(76,68), game._select_tab.bind(3),false,"quest")
	link("afk", "Supplies", Vector2(0,100), Vector2(76,68), game._journey_afk,false,"gold")
	link("gallery", "Gallery", Vector2(416,24), Vector2(76,68), game._select_tab.bind(23),false,"hero")
	link("more", "More", Vector2(416,100), Vector2(76,68), game._select_tab.bind(4),false,"settings")
	link("preview", "Art details", Vector2(372,340), Vector2(120,44), HeroShowcase.show.bind(game,"selena_preview"))
	UIDesignV2.text(self,"ATERNAL SENIA",Vector2(20,414),Vector2(452,26),18,UIDesignV2.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UIDesignV2.text(self,row.name,Vector2(20,443),Vector2(452,52),38).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	UIDesignV2.text(self,"MOONLIGHT MAGE · DESIGN PREVIEW" if row.get("preview",false) else row.title,Vector2(20,499),Vector2(452,30),13,UIDesignV2.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	link("previous", "‹", Vector2(0,450), Vector2(44,44), cycle.bind(-1))
	link("next", "›", Vector2(448,450), Vector2(44,44), cycle.bind(1))
	link("showcase", "View character", Vector2(160,538), Vector2(172,44), HeroShowcase.show.bind(game,hero_id))
	link("heroes", "Characters", Vector2(0,590), Vector2(158,130), game._select_tab.bind(23),false,"hero")
	link("summon", "Summon", Vector2(167,578), Vector2(158,142), game._select_tab.bind(11),true,"summon")
	link("journey", "Adventure", Vector2(334,590), Vector2(158,130), game._select_tab.bind(0),false,"journey")

func link(key: String, title: String, pos: Vector2, dimensions: Vector2, action: Callable, primary: bool = false, icon: String = "") -> void:
	var button := UIDesignV2.button(game,self,title,pos,dimensions,action,primary)
	actions[key] = button
	button.name = "Home_" + key
	button.tooltip_text = tr(title)
	if not icon.is_empty():
		button.text = ""
		var major := key in ["heroes","summon","journey"]
		if major:
			for state in ["normal","hover","pressed","focus"]:
				button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
			var trim := button.get_node("CelestialTrim")
			trim.queue_free()
			var crest := UIDesignV2.HomeCrest.new()
			crest.primary = primary
			crest.size = dimensions
			button.add_child(crest)
			button.mouse_entered.connect(func(): crest.modulate = Color(1.2,1.15,1.05))
			button.mouse_exited.connect(func(): crest.modulate = Color.WHITE)
			button.button_down.connect(func(): crest.scale = Vector2(.97,.97))
			button.button_up.connect(func(): crest.scale = Vector2.ONE)
		UIDesignV2.glyph(button,icon,Vector2((dimensions.x-38)/2,30 if major else 5),Vector2(38,38))
		UIDesignV2.text(button,title,Vector2(2,dimensions.y-28),Vector2(dimensions.x-4,24),17 if major else 14).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func cycle(direction: int) -> void:
	var owned: Array[String] = []
	for row in game.catalog.data.heroes:
		if game.store.available_hero(row.id): owned.append(row.id)
	if owned.is_empty(): return
	var index := owned.find(hero_id)
	game.home_hero = owned[0] if index < 0 else owned[posmod(index + direction,owned.size())]
	game._refresh_panel()
