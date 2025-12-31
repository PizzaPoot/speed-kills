extends Node2D

var player_in_hurtbox := false
var damage_player_amount := 40.0

@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var hurt_player_timer = $hurt_player_timer
@onready var pre_player_hurt_timer = $pre_hurt_player_timer

func damage_player(damage_amount, player_body):
	if player_in_hurtbox:
		print("hurting player")
		player_body.desired_speed -= damage_amount
		hurt_player_timer.start()

func _on_hurt_player_timer_timeout() -> void:
	damage_player(damage_player_amount, player)

func _on_pre_hurt_player_timer_timeout() -> void:
	damage_player(damage_player_amount, player)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name == "Player") and body.inDash == false:
		player_in_hurtbox = true
		pre_player_hurt_timer.start()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body.name == "Player") and body.inDash == false:
		player_in_hurtbox = false
