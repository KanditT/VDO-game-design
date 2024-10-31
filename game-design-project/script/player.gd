extends CharacterBody2D

const SPEED = 220.0 # Base horizontal movement speed
const ACCELERATION = 800.0 # Base acceleration
const FRICTION = 1400.0 # Base friction
const GRAVITY = 1800.0 # Gravity when moving upwards
const FALL_GRAVITY = 3000.0 # Gravity when falling downwards
const FAST_FALL_GRAVITY = 5000.0 # Gravity while holding "fast_fall"
const WALL_GRAVITY = 250. # Gravity while sliding on a wall
const JUMP_VELOCITY = -600.0 # Maximum jump strength
const WALL_JUMP_VELOCITY = -700.0 # Maximum wall jump strength
const WALL_JUMP_PUSHBACK = 300.0 # Horizontal push strength off walls
const INPUT_BUFFER_PATIENCE = 0.1 # Input queue patience time
const COYOTE_TIME = 0.1 # Coyote patience time
const DASH_SPEED = 500.0
#const ATTACK_BUFFER_PATIENCE= 0.3

var input_buffer : Timer # Reference to the input queue timer
var coyote_timer : Timer # Reference to the coyote timer
#var attacktimer : Timer
var coyote_jump_available := true
var dashed = false
var can_dash = true
var jump_count = 2
var stage2 = true
var isAttacking = false
@onready var _animated_sprite = $AnimatedSprite2D
@export var cam: Camera2D


func _ready() -> void:
	cam = get_node("Camera2D")
	# Set up input buffer timer
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)
	# Set up coyote timer
	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)

func _physics_process(delta) -> void:
	# Get inputs
	var horizontal_input := Input.get_axis("move_left", "move_right")
	var jump_attempted := Input.is_action_just_pressed("jump")
	# Add the gravity and handle jumping
	if jump_attempted or input_buffer.time_left > 0:
		if coyote_jump_available: # If jumping on the ground
			velocity.y = JUMP_VELOCITY
			coyote_jump_available = false
		elif is_on_wall() and horizontal_input != 0: # If jumping off a wall
			velocity.y = WALL_JUMP_VELOCITY
			velocity.x = WALL_JUMP_PUSHBACK * -sign(horizontal_input)
		elif jump_attempted: # Queue input buffer if jump was attempted
			input_buffer.start()
		elif jump_count > 0:
			jump_count -= 1
			velocity.y = JUMP_VELOCITY/1.2
	# Shorten jump if jump key is released
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = JUMP_VELOCITY / 4
	# Apply gravity and reset coyote jump
	if is_on_floor():
		#_on_AnimatedSprite_animation_finished()
		#_animated_sprite.play("idle")
		coyote_jump_available = true
		coyote_timer.stop()
		jump_count = 2
		if velocity.x == 0 and isAttacking == false:
			_animated_sprite.play("idle")
	if not is_on_floor():
		if not dashed and isAttacking == false :
			_animated_sprite.play("jumping")
		if _animated_sprite.animation == "jumping" and isAttacking == false:
			if Input.is_action_just_pressed("dash"):
				_animated_sprite.play("dashing")
		if coyote_jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start()
		velocity.y += get_custom_gravity(horizontal_input).y * delta

	#if jump_attempted and isAttacking == false:
		#_animated_sprite.play("jumping")
	# HYandle horizontal motion and friction
	var floor_damping := 1.0 if is_on_floor() else 0.2 # Set floor damping, friction is less when in air
	var dashinput := Input.is_action_pressed("dash")
	
	if Input.is_action_just_pressed("attack"):
		isAttacking = true
		_animated_sprite.play("attacking")
		$attackTime.start()
		
	if Input.is_action_just_pressed("dash") and can_dash:
		print(horizontal_input)
		print(position)
		dashed = true
		can_dash = false
		$dash.start()
		$can_dash.start()
		if dashed:
			if isAttacking == false:
				_animated_sprite.play("dashing")
			if horizontal_input == 0 and _animated_sprite.flip_h:
				velocity.x -= DASH_SPEED
			else:
				velocity.x += DASH_SPEED
			
	if horizontal_input != 0 and dashinput:
		if dashed:
			if isAttacking == false:
				_animated_sprite.play("dashing")
			velocity.x = 0
			velocity.x += horizontal_input * DASH_SPEED
	if _animated_sprite.animation == "dashing":
		if not _animated_sprite.is_playing():
			if not dashed:
				if isAttacking == false:
					_animated_sprite.play("walking")
		else:
			if isAttacking == false:
				_animated_sprite.play("dashing")

	if horizontal_input != 0 :
		#_animated_sprite.play("running") 
		velocity.x = move_toward(velocity.x, horizontal_input * SPEED , ACCELERATION * delta)
			# Flip sprite or play animations depending on direction
		if horizontal_input > 0:
			_animated_sprite.flip_h = false  # Face right
			if is_on_floor() and not dashinput:
				if not dashed:
					if isAttacking == false:
						_animated_sprite.play("walking")
				# Play running animation
		elif horizontal_input < 0:
			_animated_sprite.flip_h = true   # Face left
			if is_on_floor()and not dashinput:
				if not dashed:
					if isAttacking == false:
						_animated_sprite.play("walking")
			#_animated_sprite.play("running")     # Play running animation
		
	else:
		velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * floor_damping)
		
	if position.x > 3960 and stage2:
		#print(cam.is_current())
		ChangeLimit()
		stage2 = false
	if position.y > 50:
		if position.x > 5880 :
			cam.limit_left=(5725)
			cam.limit_bottom=(450)
		if position.x < 5725  :
			cam.limit_right=(5725)
			cam.limit_left=(5160)
		else:
			cam.limit_left=(5725)
			cam.limit_right=(10000)
	if position.y > 400:
		cam.limit_left=(7490)
		cam.limit_right=(8057)
		cam.limit_bottom=(816) 
		cam.limit_top=(495)
	#else :
		#cam.limit_left=(-350)
		#cam.limit_right=(3960)
	# Apply velocity
	move_and_slide()

## Returns the gravity based on the state of the player
# Rename the method to avoid conflict with PhysicsBody2D's internal get_gravity method
func get_custom_gravity(input_dir : float = 0) -> Vector2:
	var gravity_vector = Vector2(0, 0)  # Initialize a Vector2
	
	# Determine the Y-component of gravity
	if Input.is_action_pressed("fast_fall"):
		gravity_vector.y = FAST_FALL_GRAVITY
	elif is_on_wall_only() and velocity.y > 0 and input_dir != 0:
		gravity_vector.y = WALL_GRAVITY
	else:
		gravity_vector.y = GRAVITY if velocity.y < 0 else FALL_GRAVITY
	
	return gravity_vector  # Return the Vector2 with gravity applied

## Reset coyote jump
func coyote_timeout() -> void:
	coyote_jump_available = false


func _on_dash_timeout() -> void:
	dashed = false


func _on_can_dash_timeout() -> void:
	can_dash = true

func ChangeLimit() -> void:
	if cam == null:
		print("Camera is not initialized")
		return
	
	# Check if cam has the methods to set the limits individually
	cam.limit_left=(3979)
	cam.limit_right=(10000)

#func _on_AnimatedSprite_animation_finished()-> void:
	#
	#isAttacking = false


func _on_attack_time_timeout() -> void:
	isAttacking = false
