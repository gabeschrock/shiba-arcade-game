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
	"all_for_now": Info.new("All For Now", "Reach the fourth checkpoint"),
	"speedy": Info.new("Speedy", "Reach the fourth checkpoint in under 2 minutes"),
	"super_speedy": Info.new("Super Speedy", "Reach the fourth checkpoint in under 1:30"),
	"time_saver": Info.new("Time Saver", "Skip the second checkpoint"),
	"wait_thats_possible": Info.new(
		"Wait, That's Possible?",
		"Reach the fourth checkpoint in under 1 minute",
		true
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
	#var json := JSON.new()
	#var err = json.parse(content)
	#if err == OK:
		#achieved = json.data
	#else:
		#push_error(err)

func save_achievements():
	if OS.is_debug_build():
		return
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(achieved))
	file.close()

func has(id: String) -> bool:
	return id in achieved

func add(id: String) -> void:
	if has(id):
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
