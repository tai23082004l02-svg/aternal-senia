class_name HeroPortrait
extends Control

var library: FrameLibrary
var hero := "eira"
var weapon := "sword_1"

func _draw() -> void:
	if library == null:
		return
	var foot := Vector2(size.x / 2, 185)
	draw_circle(foot - Vector2(0, 83), 79, Color("152936"))
	draw_arc(foot - Vector2(0, 83), 79, -.7, 4.4, 64, Color("655d4b"), 1)
	library.draw_actor(self, library.frame_at(hero, "idle", 0), foot, weapon, Color.WHITE, true, .56 if hero == "eira" else .76)
