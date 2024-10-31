extends CharacterBody2D

var isNotHit = true
var isStart =false
const SPEED = - 300.0
@onready var animate = $AnimatedSprite2D

func _process(delta: float) -> void:
	# Add the gravity.
	if isStart:
		if isNotHit:
			if not is_on_floor():
				velocity += get_gravity() * delta
			if is_on_floor():
				animate.play("walking")
				velocity.x += SPEED * delta
			if velocity.x ==0:
				animate.play("idle")

	move_and_slide()

func _on_area_2d_body_entered(body):
	if isNotHit == false:
		queue_free()
	print(body)
	animate.play("idle")
	isNotHit = false
	#pass # Replace with function body.

func _on_area_2d_2_body_entered(body: Node2D) -> void:
	isStart = true
