extends Node
## Bundled English font roles. Never depend on device fonts for the interface.
var REGULAR: Font
var MEDIUM: Font
var SEMIBOLD: Font
var BOLD: Font
var DISPLAY: Font

var display_names: Dictionary = {}
var roster_names: Dictionary = {}

func enemy_name(saved_name: String) -> String:
	# Presentation only: never rewrite a pending encounter or its saved snapshot.
	return UIFonts.enemy_name(saved_name)

func configure(book: GameCatalog) -> void:
	for stage in book.data.stages:
		display_names[stage.name] = true
		display_names[stage.boss] = true
	for chapter in book.data.chapters: display_names[chapter.name] = true
	for entry in DungeonWorld.new().entries: display_names[entry.title] = true
	for hero in book.data.heroes: roster_names[hero.name] = true
	for spirit in book.data.assists: roster_names[spirit.name] = true

func _ready() -> void:
	# Load after asset import; preloading raw TTFs here breaks a fresh editor import.
	REGULAR = UIFonts.font("regular")
	MEDIUM = UIFonts.font("medium")
	SEMIBOLD = UIFonts.font("semibold")
	BOLD = UIFonts.font("bold")
	DISPLAY = UIFonts.font("display")
	TranslationServer.set_locale("en")
	get_tree().node_added.connect(_control_added)

func _control_added(node: Node) -> void:
	if node is Control:
		apply.call_deferred(node)

func apply(control: Control) -> void:
	if not is_instance_valid(control): return
	if control is Button:
		var action: String = control.text.to_lower()
		var font: Font = MEDIUM
		for word in ["play", "battle", "summon", "save", "claim", "confirm", "craft", "enhance", "upgrade", "continue", "start"]:
			if word in action: font = BOLD
		control.add_theme_font_override("font", font)
	elif control is Label:
		var font: Font = REGULAR
		var value: String = control.text
		var title_value := value.trim_prefix("✓ ").trim_prefix("○ ")
		var size: int = control.get_theme_font_size("font_size")
		if size >= 24: font = DISPLAY
		elif roster_names.has(value): font = MEDIUM
		if not "\n" in value and value.length() < 110:
			for title in display_names:
				if title_value == title or title_value.begins_with(title + " · ") or title_value.ends_with(" · " + title):
					font = DISPLAY
					break
		for stat in ["HP", "ATK", "DEF", "Power", "Critical", "XP:", "EXP:", "Energy", "Gold:", "LV ", "SP "]:
			if stat in value and (not "\n" in value or value.begins_with("HP ")) and value.length() < 100: font = SEMIBOLD
		if value.trim_suffix("%").is_valid_float() or value.begins_with("LV"):
			font = SEMIBOLD
		if control.has_meta("font_role"):
			font = {"display": DISPLAY, "regular": REGULAR, "medium": MEDIUM, "semibold": SEMIBOLD, "bold": BOLD}.get(control.get_meta("font_role"), font)
		control.add_theme_font_override("font", font)
