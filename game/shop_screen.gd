class_name ShopScreen
extends Control

const SECTIONS := ["Gold Shop", "Diamond Shop", "Summon", "Event Shop", "Special Offers", "Rewarded Ads"]
const ICONS := ["gold", "crystal", "summon", "event", "gift", "chest_open"]
var game
var selected := 0
var body: VBoxContainer
var tabs: Array[Button] = []

func _ready() -> void:
	custom_minimum_size = Vector2(492, 720)
	var strip := SwipeScroll.new()
	strip.size = Vector2(492, 88)
	strip.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(strip)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	strip.add_child(row)
	for i in range(SECTIONS.size()):
		var b: Button = game._button(row, SECTIONS[i], Vector2.ZERO, Vector2(120, 70), game._shop_section.bind(i))
		game.icons.tab(b, ICONS[i])
		b.custom_minimum_size = Vector2(120, 70)
		b.size = Vector2(120, 70)
		b.get_child(0).position.x = 44
		b.get_child(1).position = Vector2(3, 35)
		b.get_child(1).size = Vector2(114, 30)
		b.get_child(1).autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if i == selected: b.add_theme_stylebox_override("normal", game._style(Color("304339"), Color("dcc28a"), 10))
		tabs.append(b)
	strip.set_deferred("scroll_horizontal", maxi(0, selected * 128 - 160))
	var content := SwipeScroll.new()
	content.position = Vector2(0, 96)
	content.size = Vector2(492, 624)
	content.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(content)
	body = VBoxContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	content.add_child(body)
	var previous: VBoxContainer = game.panel
	game.panel = body
	if selected == 2:
		game._summon_panel(true)
	else:
		game._text(SECTIONS[selected].to_upper(), 23, Color("e5cd9e"))
		match selected:
			0:
				game._text("Spend Gold earned on your journey on materials and experience.")
				for id in LocalShop.OFFERS:
					var offer: Dictionary = LocalShop.OFFERS[id]
					game._text(offer.name, 19, Color("e5cd9e"))
					game._text("+%d XP" % offer.xp if offer.xp > 0 else "+%d Crystals" % offer.shards)
					game._row("Buy · %d Gold" % offer.gold, game._shop_buy_confirm.bind(id), game._locked() or game.store.profile.gold < offer.gold)
				for id in Supplies.SHOP:
					var offer: Button = game._row(Supplies.NAMES[id]+" · %d Gold" % Supplies.SHOP[id],game._supply_confirm.bind("buy",id,0),game._locked() or game.store.profile.gold<Supplies.SHOP[id])
					offer.icon = Supplies.icon(id)
					offer.expand_icon = true
					offer.add_theme_constant_override("icon_max_width",32)
				game._row("Go to Forge →", game._select_tab.bind(19))
			1:
				game._text("Diamond items will appear here when the shop opens.")
				game._row("Not on sale yet", Callable(), true)
			3:
				game._text("No event is currently running.")
				game._row("No event items yet", Callable(), true)
			4:
				game._text("No special offers are on sale yet.")
				game._row("No packs available", Callable(), true)
			5:
				game._text("Rewarded ads are not available yet.")
				game._row("Ads are not available yet", Callable(), true)
	game.panel = previous
