extends RigidBody2D

var speed := 100.0
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
	#player.Dash_raycast.is_colliding()
	
	move_and_collide(velocity)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		print("player in enemy area")


func _on_player_pointing_at_enemy(enemy: Variant) -> void:
	if enemy == self:
		slime_sprite.material = newMaterial
	else:
		slime_sprite.material = ShaderMaterial.new()
