extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var isidle = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if is_on_floor() and isidle:
		$AnimatedSprite2D.play("default")
		
	move_and_slide()


func _on_area_2d_body_entered(body):
	if body.name == "player":
		isidle =false
		velocity.x = -400
		$AnimatedSprite2D.play("attack")
