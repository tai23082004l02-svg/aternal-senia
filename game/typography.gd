extends Node
## Bundled English font roles. Never depend on device fonts for the interface.
var REGULAR: Font
var MEDIUM: Font
var SEMIBOLD: Font
var BOLD: Font
var DISPLAY: Font

func enemy_name(saved_name: String) -> String:
	# Presentation only: never rewrite a pending encounter or its saved snapshot.
	return UIFonts.enemy_name(saved_name)

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
	if control is Label or control is Button or control is LineEdit or control is TextEdit:
		control.add_theme_font_override("font", DISPLAY)
	elif control is RichTextLabel:
		for key in ["normal_font", "bold_font", "italics_font", "bold_italics_font", "mono_font"]:
			control.add_theme_font_override(key, DISPLAY)
