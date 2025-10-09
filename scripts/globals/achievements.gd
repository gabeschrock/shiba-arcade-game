extends Node

const Achievement = preload("res://scripts/achievement.gd")
const ACHIEVEMENT = preload("res://scenes/achievement.tscn")

class Info extends RefCounted:
	var name: String
	var description: String
	var secret: bool
	
	func _init(p_name: String, p_description: String, p_secret := false) -> void:
		name = p_name
		description = p_description
		secret = p_secret

var info := {
	"the_end": Info.new("The End...", "Reach the fifth checkpoint"),
	"speedy": Info.new("Speedy", "Reach the fifth checkpoint in under 3 minutes"),
	"super_speedy": Info.new("Super Speedy", "Reach the fifth checkpoint in under 2 minutes"),
	"time_saver": Info.new("Time Saver", "Skip the second checkpoint"),
	"wait_thats_possible": Info.new(
		"Wait, That's Possible?",
		"Reach the fourth checkpoint in under 1:30",
		true
	),
	"pro_gamer": Info.new(
		"Pro Gamer",
		"Reach the fourth checkpoint on impossible difficulty"
	)
}
const PATH = "user://achievements.json"

var achieved := {}
var toast: Achievement

func _ready() -> void:
	load_achievements()

func load_achievements():
	if OS.is_debug_build() or not FileAccess.file_exists(PATH):
		return
	var file := FileAccess.open(PATH, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	achieved = JSON.parse_string(content)
	var save := false
	for id in achieved:
		if id not in info:
			save = true
			achieved.erase(id)
	if save:
		save_achievements()

func save_achievements():
	if OS.is_debug_build():
		return
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(achieved))
	file.close()

func has(id: String) -> bool:
	return id in achieved

func add(id: String, min_difficulty := Settings.Difficulty.NORMAL) -> void:
	if has(id) or Settings.difficulty < min_difficulty:
		return
	achieved[id] = null
	save_achievements()
	var achievement := ACHIEVEMENT.instantiate()
	achievement.id = id
	achievement.show_secret = true
	while toast and is_instance_valid(toast) and not toast.is_queued_for_deletion():
		await toast.toast_done
	Settings.player.get_node("GUI").add_child(achievement)
	toast = achievement
	achievement.toast()

func reset() -> void:
	achieved = {}
	save_achievements()
