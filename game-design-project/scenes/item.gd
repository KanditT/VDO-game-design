extends Area2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#$AnimatedSprite2D.play("default")
func _ready() -> void:
	$AnimatedSprite2D.play("default")
func _on_body_entered(body):
	if body.name == "player":
		$AnimatedSprite2D.play("new_animation")
		$"..".coins += 1
		print($"..".coins)
		await $AnimatedSprite2D.animation_finished
		queue_free()


#func _on_animated_sprite_2d_animation_finished():
	#if $AnimatedSprite2D.animation == "new_animation":
		#queue_free() # Replace with function body.
