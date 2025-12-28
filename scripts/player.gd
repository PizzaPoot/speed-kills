extends CharacterBody2D

var SPEED := 200.0
var DashSpeed := 1500.0 #TODO scale with speed
var turn_speed_divider := 20
var freezeTime = false
@onready var input_vector = $Input_vector #debug
@onready var current_vector = $Current_vector #debug
@onready var temp_dash_visual = $Temp_dash_visual
@onready var dash_timer = $DashTimer
@onready var dash_cooldown = $DashCooldown

var turn_speed : float = clamp(turn_speed_divider/SPEED,0,1)
var targetDirection := Vector2.RIGHT
var moveDirection := Vector2.RIGHT
var dashVector := Vector2.RIGHT
var inDash := false

func getDashVelocity(): #set moving to dash direction, move to end of dash vector fast
	moveDirection = Vector2.RIGHT.rotated(dashVector.angle())
	targetDirection = moveDirection
	inDash = true
	dash_timer.start()
	return moveDirection * 1000

func dashVisualizer():
	var mousePos := get_local_mouse_position()
	var dashAngle := mousePos.angle()
	dashVector = Vector2.RIGHT.rotated(dashAngle)
	temp_dash_visual.set_point_position(1, dashVector*(DashSpeed/10))

func calculateMoveVector(newInputDirection: Vector2):
	if newInputDirection != Vector2.ZERO:
		targetDirection = newInputDirection.normalized()

	var target_angle := targetDirection.angle()
	var current_angle := moveDirection.angle()
	turn_speed = clamp(turn_speed_divider/SPEED,0,1)
	var smooth_angle := lerp_angle(current_angle, target_angle, turn_speed)
	return Vector2.RIGHT.rotated(smooth_angle)

func _on_dash_timer_timeout() -> void:
	dash_cooldown.start()
	inDash = false

func _physics_process(_delta: float) -> void:
	
	var newInputDirection = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if not inDash:
		moveDirection = calculateMoveVector(newInputDirection)

	if %GameManager.DEBUG_MODE:
		input_vector.set_point_position(1, newInputDirection.normalized()*25)
		current_vector.set_point_position(1, moveDirection*25)
	
	if Input.is_action_just_pressed("ui_accept"): # temporary for debug
		FreezeFrameManager.freezeFrame(0.5)
	
	velocity = moveDirection * SPEED
	
	if Input.is_action_pressed("dash") and dash_cooldown.is_stopped():
		dashVisualizer()
	if Input.is_action_just_released("dash") and dash_cooldown.is_stopped():
		velocity = getDashVelocity()
	if inDash:
		velocity = moveDirection * DashSpeed
	
	move_and_slide()
