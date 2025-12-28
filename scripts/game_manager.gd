extends Node

@onready var debug_UI_Timer = %debug_timer
var elapsed_time := 0.0
var seconds := 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	debug_UI_Timer.set_text("
	Freeze timer: %s
	elapsed_time: %s
	delta: %s
	player speed: %s
	turn_speed: %s" % 
	[FreezeFrameManager.timer.time_left, 
	str(elapsed_time), 
	delta,
	%Player.SPEED,
	%Player.turn_speed])
	if elapsed_time >= seconds:
		%Player.SPEED += 10
		seconds += 1
	
