class_name UtilitiesScreen
extends VBoxContainer

var game
var entries: Dictionary = {}
var quest_badge: Label

func _ready() -> void:
	custom_minimum_size = Vector2(492, 0)
	add_theme_constant_override("separation", 7)
	label("UTILITIES", 24, Color("e5cd9e"))
	group("ACTIVITY")
	var ready := MissionBoard.ready_count(game.store.profile)
	for quest in game.catalog.data.quests:
		if quest.id not in game.store.profile.claimed and game.store.profile.metrics[quest.metric] >= quest.target: ready += 1
	entry("quests", "Missions & Rewards", "Journey missions and rewards", "quest", game._select_tab.bind(3), ready)
	entry("mail", "Mailbox", "System gifts, notices, compensation", "mail", game._utility_mail)
	entry("giftcode", "Redeem Gift Code", "Event gift codes", "gift", game._utility_giftcode)
	group("EXPLORE")
	entry("story", "Story Journal", "Replay unlocked story scenes", "journal", game._select_tab.bind(16))
	entry("boss", "Boss Guide", "Skills, weaknesses, loot", "boss", game._select_tab.bind(10))
	entry("collection", "Collection & Achievements", "Collection, achievements, rewards", "achievement", game._select_tab.bind(8))
	group("SYSTEM")
	entry("settings", "Settings", "Audio, graphics, account", "settings", game._utility_settings)
	entry("help", "Help & Support", "How to play and report bugs", "help", game._utility_help)

func label(text: String, font_size: int, color: Color) -> Label:
	var item := Label.new()
	item.text = text
	item.add_theme_font_size_override("font_size", font_size)
	item.modulate = color
	add_child(item)
	return item

func group(text: String) -> void:
	var heading := label(text, 13, Color("a6b6b2"))
	heading.custom_minimum_size.y = 24
	heading.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM

func entry(id: String, title: String, subtitle: String, icon: String, action: Callable, count: int = 0) -> void:
	var button: Button = game._button(self, "", Vector2.ZERO, Vector2(492, 61), action)
	button.tooltip_text = title
	button.add_theme_stylebox_override("normal", game._style(Color(.07, .14, .18, .86), Color("34494d"), 10))
	button.name = "Utility_" + id
	entries[id] = button
	if game.icons.textures.has(icon):
		var picture := TextureRect.new()
		picture.texture = game.icons.textures[icon]
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.position = Vector2(12, 17)
		picture.size = Vector2(28, 28)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(picture)
	else:
		var picture := UtilityIcon.new()
		picture.kind = icon
		picture.position = Vector2(13, 19)
		picture.size = Vector2(26, 26)
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(picture)
	var primary: Label = game._label(button, title, Vector2(53, 8), 17, Color("eee7d7"))
	primary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var secondary: Label = game._label(button, subtitle, Vector2(53, 34), 12, Color("a6b6b2"))
	secondary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var arrow: Label = game._label(button, "›", Vector2(465, 15), 23, Color("a6b6b2"))
	arrow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if count > 0 and game.store.profile.settings.get("notify_rewards",true):
		var badge := Label.new()
		badge.text = str(count)
		badge.position = Vector2(423, 19)
		badge.size = Vector2(27, 25)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.add_theme_font_size_override("font_size", 14)
		badge.add_theme_stylebox_override("normal", game._style(Color("793b38"), Color("b86e5e"), 12))
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(badge)
		if id == "quests": quest_badge = badge

class UtilityIcon extends Control:
	var kind := "mail"
	func _draw() -> void:
		var color := Color("d7c49e")
		match kind:
			"mail":
				draw_rect(Rect2(2, 5, 22, 16), color, false, 1.7)
				draw_polyline(PackedVector2Array([Vector2(2, 5), Vector2(13, 14), Vector2(24, 5)]), color, 1.7, true)
			"gift":
				draw_rect(Rect2(3, 10, 20, 14), color, false, 1.7)
				draw_rect(Rect2(1, 7, 24, 5), color, false, 1.7)
				draw_line(Vector2(13, 7), Vector2(13, 24), color, 1.7)
				draw_circle(Vector2(9, 4), 3.5, color, false, 1.7)
				draw_circle(Vector2(17, 4), 3.5, color, false, 1.7)
			"settings":
				draw_circle(Vector2(13, 13), 8, color, false, 1.7)
				draw_circle(Vector2(13, 13), 3, color, false, 1.7)
				for i in range(8):
					var ray := Vector2.from_angle(i * TAU / 8)
					draw_line(Vector2(13, 13) + ray * 8, Vector2(13, 13) + ray * 12, color, 2)
			"help":
				draw_circle(Vector2(13, 13), 11, color, false, 1.7)
				draw_string(UIFonts.font("medium"), Vector2(8, 20), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 19, color)
