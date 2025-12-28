extends CharacterBody2D

signal pointing_at_enemy(enemy)

var SPEED := 200.0
var turn_speed_divider := 20
var freezeTime = false
var turn_speed : float = clamp(turn_speed_divider/SPEED,0,1)
var targetDirection := Vector2.RIGHT
var moveDirection := Vector2.RIGHT
var dashVector := Vector2.RIGHT
var inDash := false
var dashed_to_enemy : RigidBody2D
var dashStartPosition := global_position
var dash_distance: float = 100.0 #TODO scale with speed
var dynamic_dash_distance : float = dash_distance
var dash_time: float = 0.1
var dash_speed: float:
	get:
		return dynamic_dash_distance / dash_time
var dash_direction: Vector2 = Vector2.ZERO:
	get:
		if inDash:
			return dashVector
		return Vector2.ZERO
		
@onready var input_vector := $Input_vector #debug
@onready var current_vector := $Current_vector #debug
@onready var dash_arrow := $Dash_arrow
@onready var dash_timer := $DashTimer
@onready var dash_cooldown := $DashCooldown
@onready var dash_shapecast := $Dash_shapecast
@onready var animated_sprite := $AnimatedSprite2D
@onready var dash_start_sfx := $DashStart
@onready var dash_sfx := $Dash
@onready var dash_sfx_cooldown := $Dash_sfx_cooldown

func handleAnimationDirections():
	var snapped_rotation : float = snappedf(snappedf(velocity.angle(), TAU/8), 0.01)
	if snapped_rotation == 0.0: # E
		animated_sprite.animation = "animationRight"
		animated_sprite.flip_h = false
	elif snapped_rotation == -0.79: # NE
		animated_sprite.animation = "animationUpDiagR"
		animated_sprite.flip_h = false
	elif snapped_rotation == -1.57: # N
		animated_sprite.animation = "animationUp"
		animated_sprite.flip_h = false
	elif snapped_rotation == -2.36: # NW
		animated_sprite.animation = "animationUpDiagR"
		animated_sprite.flip_h = true
	elif snapped_rotation == -3.14: # W
		animated_sprite.animation = "animationRight"
		animated_sprite.flip_h = true
	elif snapped_rotation == 3.14: # W
		animated_sprite.animation = "animationRight"
		animated_sprite.flip_h = true
	elif snapped_rotation == 2.36: # SW
		animated_sprite.animation = "animationDownDiagR"
		animated_sprite.flip_h = true
	elif snapped_rotation == 1.57: # S
		animated_sprite.animation = "animationDown"
		animated_sprite.flip_h = false
	elif snapped_rotation == 0.79: # SE
		animated_sprite.animation = "animationDownDiagR"
		animated_sprite.flip_h = false
	

func dashVisualizer():
	dash_arrow.visible = true
	dashVector = dashVector.direction_to(get_local_mouse_position())
	dash_shapecast.target_position = dashVector*dash_distance
	if dash_shapecast.is_colliding():
		var enemy : RigidBody2D = dash_shapecast.get_collider(0)
		if "Enemy" in enemy.get_groups():
			pointing_at_enemy.emit(enemy)
			dash_arrow.set_point_position(1, dashVector*(enemy.position - position).length())
			dashVector = dashVector.direction_to(enemy.position - position)
			dynamic_dash_distance = (enemy.position - position).length()
			dashed_to_enemy = enemy
			return
	else:
		pointing_at_enemy.emit(RigidBody2D)
	dynamic_dash_distance = dash_distance
	dash_arrow.set_point_position(1, dashVector*dash_distance)

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

func _on_dash_sfx_cooldown_timeout() -> void:
	dash_start_sfx.play()

func _dash() -> void:
	velocity = dash_speed * dash_direction

func _on_enemy_touch_area_body_entered(body: Node2D) -> void:
	if body == dashed_to_enemy:
		dashed_to_enemy.damage(SPEED)


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
	
	if Input.is_action_just_pressed("dash") and dash_cooldown.is_stopped() and dash_timer.is_stopped():
		dash_sfx_cooldown.start()
	if Input.is_action_pressed("dash") and dash_cooldown.is_stopped() and dash_timer.is_stopped():
		Engine.time_scale = 0.5
		dashVisualizer()
	if Input.is_action_just_released("dash") and dash_cooldown.is_stopped() and dash_timer.is_stopped():
		Engine.time_scale = 1
		dash_timer.start()
		dash_sfx_cooldown.stop()
		inDash = true
		dash_arrow.visible = false
		targetDirection = dashVector
		moveDirection = dashVector
		dash_sfx.play()
		pointing_at_enemy.emit(RigidBody2D)
	
	if inDash:
		_dash()
		
	handleAnimationDirections()
	
	move_and_slide()
