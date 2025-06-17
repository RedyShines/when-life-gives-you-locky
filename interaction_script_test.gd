extends CollisionShape3D


func _on_interactable_interacted(interactor: Interactor) -> void:
	print("Hello I am " + str(self))
