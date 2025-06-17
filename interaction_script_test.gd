extends Node3D

func _on_interactable_interacted(interactor: Interactor) -> void:
	print("I am positioned at" + str(global_position))
