class_name UIFonts
extends RefCounted
## Lazy font resources work in fresh imports and standalone SceneTree test scripts.
const PATHS := {
	"regular": "res://art/fonts/PlayfairDisplay-Bold.ttf",
	"medium": "res://art/fonts/PlayfairDisplay-Bold.ttf",
	"semibold": "res://art/fonts/PlayfairDisplay-Bold.ttf",
	"bold": "res://art/fonts/PlayfairDisplay-Bold.ttf",
	"display": "res://art/fonts/PlayfairDisplay-Bold.ttf",
}
static var fonts: Dictionary = {}
static var legacy_enemy_names: Dictionary = {}

static func font(role: String) -> Font:
	if not fonts.has(role): fonts[role] = load(PATHS[role])
	return fonts[role]

static func enemy_name(saved_name: String) -> String:
	if legacy_enemy_names.is_empty():
		legacy_enemy_names = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/legacy_enemy_names.json"))
	return legacy_enemy_names.get(saved_name, saved_name)
