extends CharacterBody2D

var speed := 100.0
var health := 100.0
var isDead : bool = false
var newMaterial = ShaderMaterial.new()

@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var enemy_sprite = $AnimatedSprite2D
@onready var OutlineShader = preload("res://assets/shaders/Outer_outline.gdshader")

func _ready() -> void:
	newMaterial.shader = OutlineShader
	add_to_group("Enemy")
# Called when the node enters the scene tree for the first time.

func _physics_process(delta: float) -> void:
	velocity = position.direction_to(player.position) * speed * delta
	
	move_and_collide(velocity)

func kill():
	isDead = true
	get_tree().call_group("player", "on_enemy_killed", self)
	self.set_deferred("freeze", true)
	get_node("CollisionShape2D").queue_free()
	get_node("Enemy_damage_manager").queue_free()
	enemy_sprite.animation = "death"

func _on_death_animation_finished() -> void:
	self.queue_free()

func damage(damage_dealt):
	health -= damage_dealt
	if health <= 0:
		kill()

func player_pointing_at_enemy(enemy: Variant) -> void:
	if enemy == self:
		enemy_sprite.material = newMaterial
	else:
		enemy_sprite.material = ShaderMaterial.new()
