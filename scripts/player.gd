extends CharacterBody2D

var SPEED := 50.0
var turn_speed_divider := 20
var freezeTime = false
var DEBUG_GRAPHICS = true
@onready var input_vector = $Input_vector
@onready var current_vector = $Current_vector

var turn_speed : float = clamp(turn_speed_divider/SPEED,0,1)
var targetDirection: Vector2 = Vector2.RIGHT
var moveDirection: Vector2 = Vector2.RIGHT

func _physics_process(_delta: float) -> void:
	
	var newInputDirection = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	if newInputDirection != Vector2.ZERO:
		targetDirection = newInputDirection.normalized()

	var target_angle := targetDirection.angle()
	var current_angle := moveDirection.angle()
	turn_speed = clamp(turn_speed_divider/SPEED,0,1)
	var smooth_angle := lerp_angle(current_angle, target_angle, turn_speed)
	moveDirection = Vector2.RIGHT.rotated(smooth_angle)

	if DEBUG_GRAPHICS:
		input_vector.set_point_position(1, newInputDirection.normalized()*25)
		current_vector.set_point_position(1, moveDirection*25)
	
	if Input.is_action_just_pressed("ui_accept"): # temporary for debug
		FreezeFrameManager.freezeFrame(0.5)
	
	velocity = moveDirection * SPEED
	
	move_and_slide()
