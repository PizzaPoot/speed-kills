extends CharacterBody2D

@onready var debug_UI_Timer = %debug_timer
@export var SPEED : float = 130.0
var freezeTime = false

func _physics_process(_delta: float) -> void:

	var inputDirection = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if Input.is_action_just_pressed("ui_accept"):
		freezeTime = true
		FreezeFrameManager.freezeFrame(0.5, 0.1)
	velocity = inputDirection * SPEED
	
	move_and_slide()

func _process(_delta: float) -> void:
	if freezeTime:
		debug_UI_Timer.set_text("Freeze timer: "+str(FreezeFrameManager.timer.time_left))
