extends Node

const ACHIEVEMENT = preload("res://scenes/achievement.tscn")

const INFO := {
	"all_for_now": ["All For Now", "Reach the fourth checkpoint"]
}
const PATH = "user://achievements.json"

var achieved := {}

func _ready() -> void:
	load_achievements()

func load_achievements():
	if not FileAccess.file_exists(PATH):
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
	Settings.player.get_node("GUI").add_child(achievement)
	achievement.toast()

func reset() -> void:
	achieved = {}
	save_achievements()
