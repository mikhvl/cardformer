extends CharacterBody2D


@export var movement_data : PlayerMovementData
@onready var player_starting_position := self.global_position

@onready var gravity: float = ProjectSettings.get_setting('physics/2d/default_gravity')

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_jump_timer: Timer = $Timers/CoyoteJumpTimer
var was_on_floor: bool = true
var did_air_jump: bool = false
var did_wall_jump: bool = false

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func perform_jump() -> void:
	velocity.y = Vector2.UP.y * abs(
		movement_data.jump_velocity +
		movement_data.speed_jump_mult * movement_data.jump_velocity * 
		abs(velocity.x) / movement_data.top_speed
	)
	print(velocity.y)

func handle_jump(delta: float) -> void:
	if is_on_floor():
		did_air_jump = false
	if Input.is_action_just_pressed("platformer_jump"):
		if is_on_floor():
			perform_jump()
		else:
			if coyote_jump_timer.time_left > 0:
				coyote_jump_timer.stop()
				perform_jump()
			elif not did_air_jump and not did_wall_jump:
				did_air_jump = true
				perform_jump()
	if Input.is_action_just_released('platformer_jump') and not is_on_floor() and velocity.y < 0:
		velocity.y = 0

func handle_acceleration(input_axis: float, delta: float) -> void:
	if input_axis != 0:
		var deaccel_on_turn: float = 0.0
		if sign(velocity.x) != sign(input_axis):
			if is_on_floor():
				deaccel_on_turn = movement_data.acceleration / 2
			else:
				deaccel_on_turn = movement_data.acceleration
		velocity.x = move_toward(
			velocity.x,
			sign(input_axis) * movement_data.top_speed, 
			(movement_data.acceleration + deaccel_on_turn) * delta
		)
	else:
		if is_on_floor():
			velocity.x = move_toward(
				velocity.x, 0, movement_data.friction * delta
			)
		else:
			velocity.x = move_toward(
				velocity.x, 0, movement_data.air_friction * delta
			)
		
		
func handle_coyote() -> void:
	if was_on_floor == true and not is_on_floor() and velocity.y >= 0:
		coyote_jump_timer.start(movement_data.coyote_jump_timer)
	was_on_floor = is_on_floor()

func perform_animation():
	var speed_fraction = velocity.x / movement_data.top_speed
	if sign(velocity.x) == -1 and not animated_sprite_2d.flip_h:
		animated_sprite_2d.flip_h = true
	elif sign(velocity.x) == 1 and animated_sprite_2d.flip_h:
		animated_sprite_2d.flip_h = false
	if velocity.x != 0:
		animated_sprite_2d.play("walk", abs(speed_fraction))
	else:
		animated_sprite_2d.play("walk")
		animated_sprite_2d.stop()
	animated_sprite_2d.rotation_degrees = speed_fraction * movement_data.max_tilt_angle

func handle_wall_jump():
	if not is_on_wall(): 
		did_wall_jump = false
	else:
		var wall_normal = get_wall_normal()
		if Input.is_action_just_pressed("platformer_jump") and not is_on_floor():
			velocity.x = movement_data.top_speed * wall_normal.x
			velocity.y = Vector2.UP.y * abs(movement_data.jump_velocity)
			did_wall_jump = true
		

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump(delta)
	var input_axis = Input.get_axis("platformer_left", "platformer_right")
	handle_acceleration(input_axis, delta)
	perform_animation()
	handle_coyote()
	
	move_and_slide()
