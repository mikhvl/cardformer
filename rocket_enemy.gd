extends CharacterBody2D

@export var rocket_instance : PackedScene
@onready var rocket_timer : Timer = $RocketLaunchTimer

var target = null

func _ready() -> void:
	rocket_timer.start(randi_range(2, 4))

func shoot():
	var b = rocket_instance.instantiate() as Missile
	add_child(b)
	b.global_position = self.global_position
	if target != null:
		b.target = target


func _on_rocket_launch_timer_timeout() -> void:
	shoot()
	rocket_timer.start(randi_range(2, 4))


func _on_enemy_detector_body_entered(body: Node2D) -> void:
	print(body)
	if body.name == "PlatformerPlayer" and target == null:
		target = body


func _on_enemy_detector_body_exited(body: Node2D) -> void:
	if target != null and body == target:
		target = null
