extends CharacterBody2D

class_name Damageable

const SPEED = 300.0
const JUMP_VELOCITY = -150.0
const GRAVITY = 300.0 # Gravity when moving upwards
const FALL_GRAVITY = 300.0

var isnotdead = true
var countdead = true
#@onready var animate = $"../AnimatedSprite2D"

@export var health: float = 2

var count = true
var direc = false
@export var starting_md : Vector2 = Vector2.LEFT
@export var right : Vector2 = Vector2.RIGHT
@export var mm_s : float = 50.0
@onready var animate = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	var direction : Vector2 = starting_md# Add the gravity.
	var direction2 : Vector2 = right# Add the gravity.
	if isnotdead:
		if count:
			count =false
			$Timer.start()
		if is_on_floor():
			print(direction)#animate.play("chasing")
			velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			animate.play("chasing")
			velocity.y += get_custom_gravity(1).y * delta
		if direc == false:
			animate.flip_h = true
			velocity.x = direction.x * mm_s
		elif direc == true:
			animate.flip_h = false
			velocity.x = direction2.x * mm_s
	else:
		if countdead:
			velocity.y = 200
			velocity.x = 0
			countdead =false
			animate.play("dead")
			$died.start()
			
			#velocity.x = move_toward(velocity.x,0, mm_s)
	move_and_slide()
	
func hit(damage : int):
	health -= damage
	print(health)
	if (health <= 0 ):
		isnotdead = false
		

func _on_died_timeout() -> void:
	queue_free()
	
func get_custom_gravity(input_dir : float = 0) -> Vector2:
	var gravity_vector = Vector2(0, 0)  # Initialize a Vector2
	gravity_vector.y = GRAVITY if velocity.y < 0 else FALL_GRAVITY
	return gravity_vector  # Return the Vector2 with gravity applied


func _on_timer_timeout() -> void:
	direc = not direc
	count = true


func _on_deadanima_timeout() -> void:
	pass # Replace with function body.
