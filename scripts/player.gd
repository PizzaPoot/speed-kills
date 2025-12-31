extends CharacterBody2D

const MOVE_DIRECTIONS := {
	0.0: "east",
	-0.79: "northeast",
	-1.57: "north",
	-2.36: "northwest",
	-3.14: "west",
	3.14: "west",
	2.36: "southwest",
	1.57: "south",
	0.79: "southeast"
}
## direction: [animation name, flip_h]
const DIRECTIONAL_ANIMATIONS := {
	"east": ["animationEast", false], 
	"northeast": ["animationNortheast", false],
	"north": ["animationNorth", false],
	"northwest": ["animationNortheast", true],
	"west": ["animationEast", true],
	"southwest": ["animationSoutheast", true],
	"south": ["animationSouth", false],
	"southeast": ["animationSoutheast", false],
}

@export var acceleration_curve : Curve

var desired_speed := 200.0
var current_speed := 200.0
var max_speed := 200.0
var acceleration := 1.0
var turn_speed_divider := 20
var wall_slowdown_weight := 0.1
var turn_speed : float = clamp(turn_speed_divider/desired_speed,0,1)
var targetDirection := Vector2.RIGHT
var moveDirection := Vector2.RIGHT
var dashVector := Vector2.RIGHT
var inDash := false
var dashed_to_enemy : CharacterBody2D
var selected_enemy : CharacterBody2D
var damaged_enemy : CharacterBody2D
var enemies_in_area := []
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
	var animation_parameters = DIRECTIONAL_ANIMATIONS[MOVE_DIRECTIONS[snapped_rotation]]
	animated_sprite.animation = animation_parameters[0]
	animated_sprite.flip_h = animation_parameters[1]

func dashVisualizer():
	dash_arrow.visible = true
	dashVector = dashVector.direction_to(get_local_mouse_position())
	dash_shapecast.target_position = dashVector*dash_distance
	if dash_shapecast.is_colliding():
		var enemy : CharacterBody2D = dash_shapecast.get_collider(0)
		if "Enemy" in enemy.get_groups():
			get_tree().call_group("Enemy", "player_pointing_at_enemy", enemy)
			dash_arrow.set_point_position(1, dashVector*(enemy.position - position).length())
			dashVector = dashVector.direction_to(enemy.position - position)
			dynamic_dash_distance = (enemy.position - position).length()
			selected_enemy = enemy
			return
	else:
		get_tree().call_group("Enemy", "player_pointing_at_enemy", null)
	selected_enemy = null
	dynamic_dash_distance = dash_distance
	dash_arrow.set_point_position(1, dashVector*dash_distance)

func calculateMoveVector(newInputDirection: Vector2):
	if newInputDirection != Vector2.ZERO:
		targetDirection = newInputDirection.normalized()

	var target_angle := targetDirection.angle()
	var current_angle := moveDirection.angle()
	turn_speed = clamp(turn_speed_divider/desired_speed,0,1)
	var smooth_angle := lerp_angle(current_angle, target_angle, turn_speed)
	return Vector2.RIGHT.rotated(smooth_angle)

func _on_dash_timer_timeout() -> void:
	print("dash timer timeout")
	inDash = false

func _on_dash_sfx_cooldown_timeout() -> void:
	dash_start_sfx.play()

func _dash() -> void:
	velocity = dash_speed * dash_direction

func _on_enemy_touch_area_body_entered(body: Node2D) -> void:
	print("adding enemy to area list: ", body)
	if body == dashed_to_enemy and dashed_to_enemy != damaged_enemy:
		damaged_enemy = dashed_to_enemy
		dashed_to_enemy.damage(desired_speed)
	enemies_in_area.append(body)

func _on_enemy_touch_area_body_exited(body: Node2D) -> void:
	print("removing enemy from area list: ", body)
	enemies_in_area.erase(body)

func on_enemy_killed(killed_enemy):
	print("enemy killed (from player)")
	print("killed enemy: ", killed_enemy)
	enemies_in_area.erase(killed_enemy)
	print("removed enemy from list: ", enemies_in_area)
	FreezeFrameManager.freezeFrame(0.4)
	dash_cooldown.stop()

func _physics_process(_delta: float) -> void:

	acceleration_curve.max_domain = max_speed
	acceleration = acceleration_curve.sample(current_speed)
	
	var newInputDirection = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	if not inDash:
		moveDirection = calculateMoveVector(newInputDirection)
		
		 
	var try_current_speed = get_real_velocity().length()
	if str(try_current_speed) != "nan" and str(try_current_speed) != "inf": #HACK this is really bad. 
		current_speed = try_current_speed									#But timescale = 0 will make it nan or inf

	if current_speed < desired_speed:
		desired_speed = lerp(desired_speed, current_speed, wall_slowdown_weight) 
	
	if desired_speed < max_speed:
		desired_speed += acceleration
		
	if %GameManager.DEBUG_MODE:
		input_vector.set_point_position(1, newInputDirection.normalized()*25)
		current_vector.set_point_position(1, moveDirection*25)
	
	if Input.is_action_just_pressed("ui_accept"): # temporary for debug
		FreezeFrameManager.freezeFrame(0.5)
	
	velocity = moveDirection * desired_speed
	
	if Input.is_action_just_pressed("dash") and dash_cooldown.is_stopped() and dash_timer.is_stopped():
		dash_sfx_cooldown.start()
	if Input.is_action_pressed("dash") and dash_cooldown.is_stopped() and dash_timer.is_stopped():
		Engine.time_scale = 0.5
		dashVisualizer()
	if Input.is_action_just_released("dash") and dash_cooldown.is_stopped() and dash_timer.is_stopped():
		Engine.time_scale = 1
		dash_timer.start()
		dash_cooldown.start()
		dash_sfx_cooldown.stop()
		inDash = true
		dash_arrow.visible = false
		targetDirection = dashVector
		moveDirection = dashVector
		desired_speed = max_speed
		dashed_to_enemy = selected_enemy
		if dashed_to_enemy in enemies_in_area and dashed_to_enemy != damaged_enemy:
			damaged_enemy = dashed_to_enemy
			print("dash release kill")
			dashed_to_enemy.damage(desired_speed)
		dash_sfx.play()
		get_tree().call_group("Enemy", "player_pointing_at_enemy", null)
	
	if inDash:
		_dash()

	handleAnimationDirections()
	
	move_and_slide()
