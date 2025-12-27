extends Node
@onready var timer = get_tree().create_timer(0, true, false, true)
func freezeFrame(freezeTime: float, timeScale: float = 0):
	Engine.time_scale = timeScale
	timer = get_tree().create_timer(freezeTime, true, false, true)
	await timer.timeout
	Engine.time_scale = 1
