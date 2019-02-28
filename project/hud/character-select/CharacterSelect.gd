extends Control

onready var boxes = $Boxes.get_children()

var available_characters
var starting_game = false

func _ready():
	available_characters = $Boxes/SelectionBox0.CHARACTERS.duplicate()

	for i in range(boxes.size()):
		boxes[i].connect("selected", self, "_on_box_selected")
		boxes[i].connect("unselected", self, "_on_box_unselected")
		boxes[i].connect("readied", self, "_on_box_readied")
		boxes[i].connect("tried_to_start", self, "_on_box_tried_to_start")
		boxes[i].set_character(0)


func _input(event):
	if event.is_action_pressed("ui_start"):
		for box in boxes:
			if box.is_closed():
				box.open_with(event)
				return
	elif event.is_action_pressed("ui_cancel"):
		# Go to previous screen
		pass


func update_boxes():
	for box in boxes:
		box.update_available_characters(available_characters)


func update_device_map():
	for box in boxes:
		if box.is_ready():
			RoundManager.device_map.append(box.device_name)


func can_start():
	var ready_players = 0
	
	for box in boxes:
		if box.is_open():
			return false
		
		if box.is_ready():
			ready_players += 1
	
	if ready_players > 1:
		return true
	
	return false


func start_game():
	if starting_game:
		return
	
	starting_game = true
	
	update_device_map()
	
	if RoundManager.gamemode == "Arena":
		get_tree().change_scene("res://arena-mode/Arena.tscn")
	elif RoundManager.gamemode == "Race":
		get_tree().change_scene("res://race-mode/Race.tscn")


func _on_box_selected(character):
	available_characters.erase(character)
	update_boxes()


func _on_box_unselected(character):
	available_characters.append(character)
	update_boxes()


func _on_box_readied():
	if can_start():
		# Show "press start to begin" message
		pass


func _on_box_tried_to_start():
	if can_start():
		start_game()