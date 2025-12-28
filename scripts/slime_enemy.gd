extends RigidBody2D

var speed := 100.0
var health := 100.0
var isDead : bool = false
var velocity : Vector2
@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var slime_sprite = $AnimatedSprite2D
@onready var OutlineShader = preload("res://assets/shaders/Outer_outline.gdshader")
var newMaterial = ShaderMaterial.new()

func _ready() -> void:
	newMaterial.shader = OutlineShader
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		print("player in enemy area")

func _on_player_pointing_at_enemy(enemy: Variant) -> void:
	if enemy == self:
		slime_sprite.material = newMaterial
	else:
		slime_sprite.material = ShaderMaterial.new()
