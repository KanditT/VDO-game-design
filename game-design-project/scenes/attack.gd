extends Area2D

@export var damage : int = 1
@onready var _animated_sprite = $"../AnimatedSprite2D"

func _ready():
	monitoring = false
	
	
func _process(delta) -> void:
	var horizontal_input := Input.get_axis("move_left", "move_right")
	if horizontal_input != 0 :
		if horizontal_input > 0:
			$CollisionShape2D.position.x = 16  # Face right
		elif horizontal_input < 0:
			$CollisionShape2D.position.x = -16
	if _animated_sprite.animation == "attacking":
		monitoring = true
	else:
		monitoring = false

func _on_body_entered(body):
	print(body.name +  _animated_sprite.animation )
	if (body.name != "player"  ):
	#for child in body.get_children():
		if body is Damageable:
			print_debug(body.name + " took " + str(damage))
			body.hit(damage)
		if body is DamageableChest:
			body.hit(damage)
