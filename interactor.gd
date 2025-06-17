extends Area3D

class_name Interactor

var controller: Node3D

func interact(interactable: Interactable) -> void:
	interactable.interacted.emit(self) #For when the object is currently focussed on (closest to player)

func focus(interactable: Interactable) -> void:
	interactable.focussed.emit(self) #For when the object is not being focussed on (in an area3d node)

func unfocus(interactable: Interactable) -> void:
	interactable.unfocussed.emit(self) #For when the object has been interacted with

func get_nearest_interactable() -> Interactable:
	'''Checks all the interactables within an Area3D and checks which one is closest to the
	Global position of that Area3D and updates as sees fit.'''
	var list: Array[Area3D] = get_overlapping_areas()
	var distance: float
	var nearest_distance: float = INF
	var nearest: Interactable = null
	
	#Stars the check
	for interactable in list:
		#Gives each interactable a distance compared to the global position of x
		distance = interactable.global_position.distance_to(global_position)
		
		if distance < nearest_distance: #Checks if the distance compared to the current closest object is closer
			nearest = interactable as Interactable #Gives the nearest variable a value
			nearest_distance = distance #Replaces the old closest distance with the newer one
	return nearest
