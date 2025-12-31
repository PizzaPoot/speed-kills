extends Node
var time_frozen := false 
@onready var timer = get_tree().create_timer(0, true, false, true)
func freezeFrame(freezeTime: float, timeScale: float = 0):
	time_frozen = true
	Engine.time_scale = timeScale
	timer = get_tree().create_timer(freezeTime, true, false, true)
	await timer.timeout
	Engine.time_scale = 1
	time_frozen = false
