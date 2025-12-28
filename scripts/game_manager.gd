extends Node

@onready var debug_UI_Timer = %debug_timer
var elapsed_time := 0.0
var elapsed_seconds := 1
var DEBUG_MODE := true
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
	turn_speed: %s
	dash_cooldown: %s" % 
	[FreezeFrameManager.timer.time_left, 
	str(elapsed_time), 
	delta,
	%Player.SPEED,
	%Player.turn_speed,
	$"../Player/DashCooldown".time_left])
	if elapsed_time >= elapsed_seconds:
		elapsed_seconds += 1
		if not DEBUG_MODE:
			%Player.SPEED += 10
	
