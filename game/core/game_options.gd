class_name GameOptions
extends RefCounted

const DEFAULTS := {"quality":"high", "fps_limit":60, "lighting":true, "screen_shake":true, "damage_numbers":true, "battery_saver":false, "reduced_effects":false, "notify_rewards":true, "prioritize_heal":true}

static func state(p: Dictionary) -> Dictionary:
	var result := DEFAULTS.duplicate(true)
	for key in DEFAULTS: result[key] = p.settings.get(key,DEFAULTS[key])
	return result

static func valid(settings: Dictionary) -> bool:
	for key in DEFAULTS:
		if not settings.has(key): continue
		if key == "quality":
			if settings[key] not in ["low","medium","high"]: return false
		elif key == "fps_limit":
			if settings[key] not in [30,60]: return false
		elif not settings[key] is bool: return false
	return not settings.has("ui_volume") or (settings.ui_volume is float or settings.ui_volume is int) and is_finite(settings.ui_volume) and settings.ui_volume >= 0 and settings.ui_volume <= 1

static func save(store: ProgressStore,values: Dictionary,formation: Dictionary = {}) -> bool:
	if not valid(values): return false
	if (not formation.is_empty() or values.has("prioritize_heal") or values.has("speed")) and not store.profile.pending.is_empty():
		store.error = "Adjust auto battle options after the battle ends."
		return false
	var p := store.profile.duplicate(true)
	for key in values:
		if key not in DEFAULTS and key not in ["sound","sfx_volume","ambience_volume","music_volume","ui_volume","speed"]: return false
		p.settings[key] = values[key]
	if not formation.is_empty():
		if not store.profile.pending.is_empty():
			store.error = "Adjust formation options after the battle ends."
			return false
		p.formation = Formation.state(p,store.catalog).duplicate(true)
		for key in formation:
			if key not in ["auto_ult","auto_next"] or not formation[key] is bool: return false
			p.formation[key] = formation[key]
	return store.commit(p)

static func export_backup(store: ProgressStore,path: String) -> bool:
	if store.read_only or not store.profile.pending.is_empty() or path.is_empty() or not store.valid(store.profile): return false
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(store.profile,"\t",true,true))
	var write_error := file.get_error()
	file.close()
	if write_error != OK: return false
	if FileAccess.file_exists(path) and DirAccess.copy_absolute(path,path+".bak") != OK: return false
	return DirAccess.rename_absolute(path+".tmp",path) == OK

static func read_backup(store: ProgressStore,path: String) -> Dictionary:
	var file := FileAccess.open(path,FileAccess.READ)
	if file == null or file.get_length() > 2097152: return {}
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or not parser.data is Dictionary: return {}
	var candidate = store._decode(path)
	if not store.valid(candidate) or not candidate.pending.is_empty(): return {}
	return candidate

static func restore_backup(store: ProgressStore,candidate: Dictionary) -> bool:
	if not store.profile.pending.is_empty() or not store.valid(candidate) or not candidate.pending.is_empty(): return false
	return store.commit(candidate.duplicate(true))
