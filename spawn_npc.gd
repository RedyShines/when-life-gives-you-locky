extends Node3D

@onready var moving_npc : PackedScene = preload("res://NPC_template.tscn")
var randint

func _process(_delta: float) -> void:
	randint = randi_range(1,400)
	if randint == 50:
		var new_npc = moving_npc.instantiate()
		
		for i in range(2):
			new_npc = moving_npc.instantiate()
			add_child(new_npc)
			
