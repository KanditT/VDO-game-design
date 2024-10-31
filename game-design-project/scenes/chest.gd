extends CharacterBody2D

class_name DamageableChest

@export var health: float = 3

var isopen = true

@onready var animate = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	if isopen:
		animate.play("default")
		
	move_and_slide()
	
func hit(damage : int):
	health -= damage
	print(health)
	if (health == 0 ):
		animate.play("opening")
		isopen = false
		
