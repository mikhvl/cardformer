class_name Missile extends RigidBody2D

@export var lifetime = 20.0

@export var max_speed = 300.0
@export var drag_factor = 0.2
@export var acceleration = 55.0

var _current_velocity = Vector2.ZERO
var _current_speed = 0

@onready var _sprite = $Sprite2D
var target = null

func _ready():
	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)
	
	_current_velocity = Vector2.RIGHT.rotated(rotation)
	
	
func _physics_process(delta: float) -> void:
	var direction := Vector2.RIGHT.rotated(rotation).normalized()
	
	if target:
		direction = global_position.direction_to(target.global_position)

	_current_speed = move_toward(_current_speed, max_speed, acceleration * delta)
	var desired_velocity = direction * _current_speed
	var previous_velocity = _current_velocity
	var change = (desired_velocity - _current_velocity) * drag_factor
	
	_current_velocity += change * delta
	
	look_at(global_position + _current_velocity)
	move_and_collide(_current_velocity * acceleration * delta)

func _on_enemy_detector_body_entered(body: Node2D) -> void:
	print(body, target)
	if body.name == 'PlatformerPlayer' and target == null:
		target = body


func _on_body_entered(body: Node) -> void:
	print(body)
	if body.name == 'PlatformerPlayer':
		pass
	queue_free()


func _on_enemy_detector_body_exited(body: Node2D) -> void:
	if target != null and body == target:
		target = null
