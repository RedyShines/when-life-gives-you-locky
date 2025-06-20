extends CharacterBody3D

@export var movement_data : NPCMovementData
@onready var nav: NavigationAgent3D = $NPCNav
@onready var front_detector: RayCast3D = $NPCModel/FrontDetector
const lerpVal = .17
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var direction = Vector3()

@onready var _1: Marker3D = $"../../Targets/1"
@onready var _2: Marker3D = $"../../Targets/2"
@onready var _3: Marker3D = $"../../Targets/3"
@onready var _4: Marker3D = $"../../Targets/4"
@onready var _5: Marker3D = $"../../Targets/5"
@onready var _6: Marker3D = $"../../Targets/6"
@onready var attribute_marker: Marker3D = $"../../Targets/NPCAttributeChanger/AttributeMarker"
@onready var store_marker: Marker3D = $"../../Targets/Store"

var targets : Array
var target
var movement_type = 1

func _ready() -> void:
	position.z = 10
	movement_data = movement_data.duplicate()
	var npc_type = randi_range(1, 10)
	if npc_type <= 3:
		target = attribute_marker
	else:
		targets = [_1, _2, _3, _4, _5, _6]
		target = targets[randi_range(0, 5)]
	movement_data.SPEED = randi_range(3, 6)


func _physics_process(delta) -> void:
	'''Allows functions to run every frame.'''
	velocity.y -= gravity * delta * 5
	handle_movement(delta)
	#handle_timers(delta)
	move_and_slide()
	if position.y < -50:
		position.y = 0


func handle_movement(delta) -> void:
	'''Handles the velocity on the x and z axis'''
	# Removes velocity.y from the velocity calculations so the functions jump controller and handle_jump can handle it
	var vy = velocity.y
	velocity.y = 0
	
	if velocity.length() > 0 or velocity.length() < 0:
		$".".rotation.y = lerp_angle($".".rotation.y, atan2(-velocity.x, -velocity.z), lerpVal)
	if front_detector.is_colliding():
		if movement_type == 0:
			movement_controller(0, movement_data.FRICTION, movement_data.AIR_ACCEL, delta)
		else:
			pass
	else:
		movement_controller(movement_data.SPEED ,movement_data.ACCELERATION, movement_data.AIR_ACCEL, delta)
		
	# Sets velocity.y back to vy
	velocity.y = vy


func movement_controller(speed, acceleration, air_acceleration, delta) -> void:
	'''Makes the NPC move.'''
#handles the acceleration of the NPC on ground and ai
	nav.target_position = target.global_position
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if global_position.distance_to(target.global_position) < 0.1\
	 and target != attribute_marker and target != store_marker:
		target = targets[randi_range(0, 5)]
	
	if is_on_floor():
		velocity = lerp(velocity, speed * direction, acceleration * delta)
		
	if not is_on_floor():
		velocity = lerp(velocity, speed * direction, air_acceleration * delta)


func _on_attribute_detector_area_entered(_area: Area3D) -> void:
	movement_type = 0
	target = store_marker
	movement_data.SPEED = 2
