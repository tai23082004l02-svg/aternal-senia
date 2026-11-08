class_name HomeScreen
extends Control
## Session-only portrait selection; never changes formation or profile avatar.
var game
var actions: Dictionary = {}
var hero_id := ""

func _ready() -> void:
	custom_minimum_size = Vector2(492, 732)
	hero_id = game.home_hero
	if hero_id.is_empty() or not game.store.available_hero(hero_id): hero_id = PlayerIdentity.state(game.store.profile).avatar
	if not game.store.available_hero(hero_id): hero_id = game.store.profile.hero
	var row: Dictionary = game.catalog.find_row("heroes", hero_id)
	UIDesignV2.art(self, load(row.art.banner), Vector2.ZERO, Vector2(492, 724))
	var top := ColorRect.new()
	top.size = Vector2(492, 78)
	top.color = Color("0c152bcc")
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(top)
	UIDesignV2.text(self, "ATERNAL SENIA", Vector2(16, 12), Vector2(330, 28), 23, UIDesignV2.GOLD)
	UIDesignV2.text(self, "Your heroes. Your next adventure.", Vector2(16, 45), Vector2(380, 24), 13)
	link("missions", "Missions", Vector2(12, 96), Vector2(100, 44), game._select_tab.bind(3))
	link("afk", "AFK Supplies", Vector2(12, 148), Vector2(100, 44), game._journey_afk)
	link("gallery", "Gallery", Vector2(380, 96), Vector2(100, 44), game._select_tab.bind(23))
	link("more", "More", Vector2(380, 148), Vector2(100, 44), game._select_tab.bind(4))
	var plaque := Panel.new()
	plaque.position = Vector2(12, 396)
	plaque.size = Vector2(468, 126)
	plaque.add_theme_stylebox_override("panel", UIDesignV2.panel())
	add_child(plaque)
	UIDesignV2.text(plaque, row.name, Vector2(16, 8), Vector2(310, 38), 30)
	UIDesignV2.text(plaque, row.title, Vector2(16, 48), Vector2(410, 24), 16, UIDesignV2.GOLD)
	UIDesignV2.text(plaque, str(row.element).capitalize() + " · " + row.role + " · 5★", Vector2(16, 82), Vector2(340, 24), 13, UIDesignV2.MUTED)
	link("showcase", "View", Vector2(388, 410), Vector2(80, 44), HeroShowcase.show.bind(game, hero_id))
	link("previous", "‹", Vector2(12, 340), Vector2(44, 44), cycle.bind(-1))
	link("next", "›", Vector2(436, 340), Vector2(44, 44), cycle.bind(1))
	link("heroes", "Heroes", Vector2(12, 540), Vector2(150, 62), game._select_tab.bind(23))
	link("summon", "Summon", Vector2(171, 540), Vector2(150, 62), game._select_tab.bind(11), true)
	link("journey", "Journey", Vector2(330, 540), Vector2(150, 62), game._select_tab.bind(0), true)
	link("formation", "Formation", Vector2(12, 614), Vector2(228, 48), game._select_tab.bind(22))
	link("bag", "Equipment & Bag", Vector2(252, 614), Vector2(228, 48), game._select_tab.bind(2))
	var footer := ColorRect.new()
	footer.position = Vector2(12, 680)
	footer.size = Vector2(468, 36)
	footer.color = Color("0c152bd9")
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(footer)
	UIDesignV2.text(self, "ZORVYKA GAMES", Vector2(12, 686), Vector2(468, 24), 12, UIDesignV2.GOLD).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func link(key: String, title: String, pos: Vector2, dimensions: Vector2, action: Callable, primary: bool = false) -> void:
	actions[key] = UIDesignV2.button(game, self, title, pos, dimensions, action, primary)
	actions[key].name = "Home_" + key
	actions[key].tooltip_text = tr(title)

func cycle(direction: int) -> void:
	var owned: Array[String] = []
	for row in game.catalog.data.heroes:
		if game.store.available_hero(row.id): owned.append(row.id)
	if owned.is_empty(): return
	game.home_hero = owned[posmod(owned.find(hero_id) + direction, owned.size())]
	game._refresh_panel()
