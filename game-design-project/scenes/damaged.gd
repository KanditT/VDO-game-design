extends Node

#class_name Damageable

#var isdead = false
#@onready var animate = $"../AnimatedSprite2D"
#
#@export var health: float = 2
#
#
#func _process(delta: float) -> void:
	#if isdead:
		#get_parent().queue_free()	

#func hit(damage : int):
	#health -= damage
	#
	#if (health <= 0 ):
		#animate.play("dead")
		#$"../died".start()
#
#func _on_died_timeout() -> void:
	#isdead = true
	#
