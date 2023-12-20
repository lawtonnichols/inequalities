extends Node

var num1 = 0
var num2 = 0
var answer = null

var less_than_starting_loc
var greater_than_starting_loc
var equal_to_starting_loc
var selected = null
var can_let_go = false
var game_won = false
var last_selected = null
var animation_started = false

var left_children
var right_children

var restart_original_loc

# Called when the node enters the scene tree for the first time.
func _ready():
	restart_original_loc = $Restart.global_position
	
	new_game()

func shuffle_cards():
	randomize()
	
	# shuffle around the cards
	var less_than = $Options/LessThan
	var greater_than = $Options/GreaterThan
	var equal_to = $Options/EqualTo
	var cards = [less_than, greater_than, equal_to]
	var spacers = [$Options/Spacer, $Options/Spacer2]
	cards.shuffle()
	for card in $Options.get_children():
		$Options.remove_child(card)
	$Options.add_child(cards[0])
	$Options.add_child(spacers[0])
	$Options.add_child(cards[1])
	$Options.add_child(spacers[1])
	$Options.add_child(cards[2])

func create_fruits():
	# clear out old fruits
	for node in $LeftGrid.get_children():
		node.queue_free()
	for node in $RightGrid.get_children():
		node.queue_free()
	
	var fruit_types = ["apple", "banana", "cherry", "kiwi", "melon", "orange", "pineapple", "strawberry"]
	var fruit_type1 = fruit_types[randi() % fruit_types.size()]
	var fruit_type2 = fruit_types[randi() % fruit_types.size()]
	while fruit_type2 == fruit_type1:
		fruit_type2 = fruit_types[randi() % fruit_types.size()]
	
	for i in range(num1):
		var fruit = load("res://fruit.tscn").instantiate()
		fruit.get_node("./AnimatedSprite2D").play(fruit_type1)
		$LeftGrid.add_child(fruit)
		
	for i in range(num2):
		var fruit = load("res://fruit.tscn").instantiate()
		fruit.get_node("./AnimatedSprite2D").play(fruit_type2)
		$RightGrid.add_child(fruit)
	
	selected = null

func new_game():
	shuffle_cards()
	
	selected = null
	last_selected = null
	can_let_go = false
	game_won = false
	animation_started = false
	
	$CrocGreaterThan.frame = 0
	$CrocLessThan.frame = 0
	$CrocGreaterThan.play()
	$CrocLessThan.play()
	$CrocGreaterThan.hide()
	$CrocLessThan.hide()
	
	$CrocTimer.stop()
	for conn in $CrocTimer.get_signal_connection_list($CrocTimer.timeout.get_name()):
		$CrocTimer.timeout.disconnect(conn.callable)
	
	$NumberSlotNumber/Slot/Hovered.hide()
	
	# pick new numbers
	var choice = randi() % 5
	if choice == 0:
		# equal
		num1 = randi() % 20 + 1
		num2 = num1
		answer = $Options/EqualTo
	elif 1 <= choice and choice <= 2:
		# <
		num1 = randi() % 20 + 1
		num2 = randi() % 20 + 1
		while num1 >= num2:
			num1 = randi() % 20 + 1
			num2 = randi() % 20 + 1
		answer = $Options/LessThan
	else:
		# >
		num1 = randi() % 20 + 1
		num2 = randi() % 20 + 1
		while num1 <= num2:
			num1 = randi() % 20 + 1
			num2 = randi() % 20 + 1
		answer = $Options/GreaterThan
	$NumberSlotNumber/LeftNum.set_text(str(num1))
	$NumberSlotNumber/RightNum.set_text(str(num2))
	
	# set fruits
	create_fruits()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected != null and not game_won:
		selected.global_position = lerp(selected.global_position, selected.get_global_mouse_position() - 0.5 * selected.get_size(), 25 * delta)
		
		# see if the correct card is over the slot
		if $NumberSlotNumber/Slot.get_global_rect().has_point(selected.get_global_mouse_position()) and selected == answer:
			can_let_go = true
		else:
			can_let_go = false
	elif can_let_go:
		game_won = true
		var final_position = $NumberSlotNumber/Slot.get_global_position()
		answer.global_position = lerp(answer.global_position, final_position, 25 * delta)
	elif last_selected != null:
		var correct_starting_position = null
		if last_selected == $Options/GreaterThan:
			correct_starting_position = greater_than_starting_loc
		elif last_selected == $Options/EqualTo:
			correct_starting_position = equal_to_starting_loc
		elif last_selected == $Options/LessThan:
			correct_starting_position = less_than_starting_loc
		last_selected.global_position = lerp(last_selected.global_position, correct_starting_position, 7 * delta)
	
	if game_won and not animation_started:
		animation_started = true
		left_children = $LeftGrid.get_children()
		right_children = $RightGrid.get_children()
		var fruit_timer = get_tree().create_timer(0.5)
		fruit_timer.timeout.connect(blow_up_fruit)
		$CrocTimer.start()
		$CrocTimer.timeout.connect(hide_crocs)
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and $NumberSlotNumber/Slot.get_global_rect().has_point($NumberSlotNumber/Slot.get_global_mouse_position()):
		$NumberSlotNumber/Slot/Hovered.show()
	else:
		$NumberSlotNumber/Slot/Hovered.hide()

func blow_up_fruit():
	var local_left_children = left_children
	var local_right_children = right_children
	
	if answer == $Options/LessThan:
		$CrocLessThan.stop()
		$CrocLessThan.play()
		$CrocLessThan.show()
		await get_tree().create_timer(0.5).timeout
		for node in local_right_children:
			node.blow_up() if node != null else null
			await get_tree().create_timer(0.1).timeout
	elif answer == $Options/GreaterThan:
		$CrocGreaterThan.stop()
		$CrocGreaterThan.play()
		$CrocGreaterThan.show()
		await get_tree().create_timer(0.5).timeout
		for node in local_left_children:
			node.blow_up() if node != null else null
			await get_tree().create_timer(0.1).timeout
	elif answer == $Options/EqualTo:
		for i in range(local_left_children.size()):
			local_left_children[i].blow_up() if i < local_left_children.size() and local_left_children[i] != null else null
			local_right_children[i].blow_up() if i < local_right_children.size() and local_right_children[i] != null else null
			await get_tree().create_timer(0.1).timeout

func hide_crocs():
	if game_won:
		$CrocLessThan.hide()
		$CrocGreaterThan.hide()

func handle_gui_input(event, node):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			selected = node
			node.z_index = 999
			if node == $Options/LessThan:
				less_than_starting_loc = node.global_position
			elif node == $Options/GreaterThan:
				greater_than_starting_loc = node.global_position
			elif node == $Options/EqualTo:
				equal_to_starting_loc = node.global_position
		else:
			selected = null
			last_selected = node
			node.z_index = 1

func _on_less_than_gui_input(event):
	handle_gui_input(event, $Options/LessThan)

func _on_greater_than_gui_input(event):
	handle_gui_input(event, $Options/GreaterThan)

func _on_equal_to_gui_input(event):
	handle_gui_input(event, $Options/EqualTo)

func _on_restart_mouse_entered():
	$Restart.global_position.y = restart_original_loc.y + 2
	await get_tree().create_timer(0.25).timeout
	$Restart.global_position.y = restart_original_loc.y	

func _on_restart_button_down():
	$Restart.global_position.y = restart_original_loc.y + 2

func _on_restart_button_up():
	$Restart.global_position.y = restart_original_loc.y
	new_game()
