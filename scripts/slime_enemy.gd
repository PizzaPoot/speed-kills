extends RigidBody2D

var speed := 100.0
var velocity : Vector2
@onready var player = get_tree().get_nodes_in_group("player")[0]
# Called when the node enters the scene tree for the first time.

func _physics_process(delta: float) -> void:
	
	velocity = position.direction_to(player.position) * speed * delta
	
	move_and_collide(velocity)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		print("player in enemy area")
