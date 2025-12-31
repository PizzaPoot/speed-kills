extends CharacterBody2D

var speed := 100.0
var health := 100.0
var player_in_hurtbox := false
var damage_player_amount := 40.0
var isDead : bool = false
var newMaterial = ShaderMaterial.new()

@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var slime_sprite = $AnimatedSprite2D
@onready var OutlineShader = preload("res://assets/shaders/Outer_outline.gdshader")
@onready var hurt_player_timer = $hurt_player_timer

func _ready() -> void:
	newMaterial.shader = OutlineShader
	add_to_group("Enemy")
# Called when the node enters the scene tree for the first time.

func _physics_process(delta: float) -> void:
	velocity = position.direction_to(player.position) * speed * delta
	
	move_and_collide(velocity)

func kill():
	isDead = true
	self.set_deferred("freeze", true)
	get_node("CollisionShape2D").queue_free()
	slime_sprite.animation = "death"

func _on_death_animation_finished() -> void:
	self.queue_free()

func damage(damage_dealt):
	health -= damage_dealt
	if health <= 0:
		kill()

func damage_player(damage_amount, player_body):
	if player_in_hurtbox:
		player_body.desired_speed -= damage_amount
		hurt_player_timer.start()

func _on_hurt_player_timer_timeout() -> void:
	damage_player(damage_player_amount, player)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player") and body.inDash == false:
		player_in_hurtbox = true
		damage_player(damage_player_amount, body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body.name == "Player") and body.inDash == false:
		player_in_hurtbox = false

func player_pointing_at_enemy(enemy: Variant) -> void:
	if enemy == self:
		slime_sprite.material = newMaterial
	else:
		slime_sprite.material = ShaderMaterial.new()
