extends Interactor

@export var player: CharacterBody3D

var saved_closest: Interactable

func _ready() -> void:
	controller = player

func _process(delta: float) -> void:
	'''Runs Processes every frame.
	For this case, it replaces the currently closest object with the newest closest
	object if it requires to do so'''
	var new_closest: Interactable = get_nearest_interactable() #Gets the closest object
	if new_closest != saved_closest: # Checks if the object is new or not
		if is_instance_valid(saved_closest): #Checks if the old object is valid
			unfocus(saved_closest) #Unfocusses on the old closest
		if new_closest: 
			focus(new_closest) #Focusses on the new closest
		saved_closest = new_closest

func _input(event: InputEvent) -> void:
	'''Handles the input.
	For this case, it handles the input when interacting with interactable objects'''
	if event.is_action_pressed("interact"):
		if saved_closest: #Checks if the interacted object is the closest object
			interact(saved_closest) #Interact
