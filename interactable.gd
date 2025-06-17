extends Area3D

class_name Interactable

signal focussed(interactor: Interactor) #signal for when the object is currently focussed on (closest to player)

signal unfocussed(interactor: Interactor) #signal for when the object is not being focussed on (in an area3d node)

signal interacted(interactor: Interactor) #signal for when the object has been interacted with
