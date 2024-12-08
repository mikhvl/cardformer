extends RigidBody2D

@export var lifetime = 20.0

@export var max_speed = 300.0
@export var drag_factor = 0.05
@export var acceleration = 65.0

var _current_velocity = Vector2.ZERO
var _current_speed = 0

@onready var _sprite = $Sprite2D
@onready var target: CharacterBody2D = get_tree().get_nodes_in_group("PlatformerPlayer")[0]

@onready var _collision: Area2D = $EnemyDetector

func _ready():
	_collision.body_entered.connect(queue_free)
	
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
	
	position += _current_velocity * acceleration * delta
	for b in get_colliding_bodies():
		queue_free()
	look_at(global_position + _current_velocity)
