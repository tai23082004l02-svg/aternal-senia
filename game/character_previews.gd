class_name CharacterPreviews
extends RefCounted
## Explicit visual deliveries, separate from playable hero/save/summon catalogues.
static func rows() -> Array:
	var document = JSON.parse_string(FileAccess.get_file_as_string("res://game/data/character_previews.json"))
	if not document is Dictionary or document.get("version") != 1 or not document.get("characters") is Array: return []
	var result: Array = []
	for source in document.characters:
		if not source is Dictionary or not source.get("id") is String or not source.get("art") is Dictionary: continue
		if not ResourceLoader.exists(source.art.get("banner", "")): continue
		var row: Dictionary = source.duplicate(true)
		row.preview = true
		result.append(row)
	return result

static func find(id: String) -> Dictionary:
	for row in rows():
		if row.id == id: return row
	return {}
