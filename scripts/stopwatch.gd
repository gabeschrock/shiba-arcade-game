extends Node

var started := false
var start_time: int
var pause_start: int
var pause_time := 0
var time: float:
	get():
		if not started:
			return 0.0
		var mult := Engine.time_scale if OS.is_debug_build() else 1.0
		return (Time.get_ticks_usec() - start_time - pause_time) * mult / 1_000_000.0

func start():
	if not started:
		restart()

func restart():
	started = true
	start_time = Time.get_ticks_usec()
	pause_time = 0

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED:
		pause_start = Time.get_ticks_usec()
	elif what == NOTIFICATION_UNPAUSED:
		pause_time += Time.get_ticks_usec() - pause_start
