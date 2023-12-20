extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_x = region_rect.position.x - delta * 10
	var new_y = region_rect.position.y + delta * 10
	while new_x < 0:
		new_x += 64
	while new_y >= 64:
		new_y -= 64
	region_rect.position.x = new_x
	region_rect.position.y = new_y
	
