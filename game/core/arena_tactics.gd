class_name ArenaTactics
extends RefCounted

# Presentation-space speeds/ranges, independent of upgradeable character stats.
# aggression, pursuit, combo, counter, recklessness, target switch, reaction.
const PROFILES := {
	"eira": [120, 51, 80, 80, 75, 65, 55, 25, 70],
	"ryn": [110, 54, 70, 70, 60, 65, 60, 25, 65],
	"lyra": [128, 51, 85, 85, 75, 60, 65, 30, 70],
	"mira": [110, 170, 30, 35, 50, 70, 25, 25, 75],
	"caelan": [104, 56, 60, 60, 55, 70, 45, 25, 65]
}
const KEYS := ["speed", "range", "aggression", "pursuit", "combo", "counter", "recklessness", "switch", "reaction"]
static func profile(id: String) -> Dictionary:
	var values: Array = PROFILES.get(id, PROFILES.eira)
	var result := {"version":1, "evade_cooldown":4.5}
	for i in range(KEYS.size()): result[KEYS[i]] = values[i]
	return result

static func valid(value: Variant) -> bool:
	if not value is Dictionary or value.get("version") != 1 or value.size() != KEYS.size() + 2: return false
	for key in KEYS + ["evade_cooldown"]:
		var number = value.get(key)
		if not (number is int or number is float) or not is_finite(float(number)): return false
		var minimum := 50.0 if key == "speed" else (40.0 if key == "range" else (3.0 if key == "evade_cooldown" else 0.0))
		var maximum := 180.0 if key in ["speed","range"] else (10.0 if key == "evade_cooldown" else 100.0)
		if number < minimum or number > maximum: return false
	return true
