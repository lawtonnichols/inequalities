extends Control

var just_played_reverse = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.show()
	$Collected.stop()
	$Collected.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func blow_up():
	$AnimatedSprite2D.hide()
	$Collected.show()
	$Collected.play()

func _on_collected_animation_finished():
	if just_played_reverse:
		$Collected.hide()
		$AnimatedSprite2D.show()
		just_played_reverse = false
	else:
		$Collected.hide()
		await get_tree().create_timer(5.0).timeout
		just_played_reverse = true
		$Collected.show()
		$Collected.play_backwards()
	
	
