extends Control

var original_animation

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	original_animation = $AnimatedSprite2D.get_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func blow_up():
	original_animation = $AnimatedSprite2D.get_animation()
	$AnimatedSprite2D.play("collected")

func _on_animated_sprite_2d_animation_looped():
	if $AnimatedSprite2D.get_animation() == "collected":
		$AnimatedSprite2D.hide()
		await get_tree().create_timer(5.0).timeout
		if $AnimatedSprite2D.get_animation() != "collected":
			return
		$AnimatedSprite2D.play(original_animation)
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.show()

func reset_animation():
	$AnimatedSprite2D.set_frame(0)
	$AnimatedSprite2D.play(original_animation)

