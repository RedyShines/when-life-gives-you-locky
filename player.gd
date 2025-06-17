extends CharacterBody3D

var cameraX = .007
var cameraY = .005

var sprint_timer = 0
var sprint_multiplier_increase = 0
var walking = false
var sprinting = false
var max_sprinting = false
var max_sprint = 0

var input_dir
var direction

var front_normal
var back_normal
var raycast_normal = Vector3.UP

@export var movement_data : PlayerMovementData

@onready var spring_arm_pivot = $springArmPivot
@onready var spring_arm = $springArmPivot/SpringArm3D
@onready var armature = $PlayerModel

const lerpVal = .17

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta) -> void:
	'''Runs stuff every frame.'''
	
	# Kills the game when the escape key is pressed.
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()
	
	# Respawns the player at the center of the map.
	if global_position.y < -50:
		position.x = 0
		position.y = 0.1
		position.z = 0


func _unhandled_input(event) -> void:
	'''Handles mouse movement for the player for moving and zooming the camera.'''
	# Spring arm pivot camera movement.
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * cameraX)
		spring_arm.rotate_x(-event.relative.y * cameraY)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/3, PI/5)
	
	# Spring arm camera zooming.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			spring_arm.spring_length = clamp(spring_arm.spring_length - 0.5, 1, 10)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			spring_arm.spring_length = clamp(spring_arm.spring_length + 0.5, 1, 10)


func _physics_process(delta) -> void:
	'''Allows functions to run every frame.'''
	velocity.y -= gravity * delta * 5
	movement_conditions(delta)
	handle_movement(delta)
	#handle_timers(delta)
	move_and_slide()


func handle_movement(delta) -> void:
	'''Handles the velocity on the x and z axis'''
	# Removes velocity.y from the velocity calculations so the functions jump controller and handle_jump can handle it
	var vy = velocity.y
	velocity.y = 0
# Makes player rotate to face the way they are moving
	if velocity.length() > 0 or velocity.length() < 0:
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), lerpVal)
	
	if PlayerData.can_move == true:
		if sprinting == true:
			# Sprint state
			sprint_multiplier_increase += delta / 10
			movement_controller(movement_data.SPEED * (movement_data.SPRINT_MULTIPLIER + sprint_multiplier_increase) \
			,movement_data.SPRINT_ACCELERATION, \
			movement_data.SPRINT_AIR_ACCEL, movement_data.SPRINT_FRICTION, movement_data.SPRINT_AIR_RESISTANCE, delta)
		
		elif max_sprinting == true:
			# Max sprint state
			sprint_multiplier_increase = 0
			movement_controller(movement_data.SPEED * movement_data.MAX_SPRINT_MULTIPLIER, movement_data.MAX_ACCELERATION, movement_data.MAX_AIR_ACCEL, \
					movement_data.SPRINT_FRICTION, movement_data.SPRINT_AIR_RESISTANCE, delta)
		
		elif walking == true:
			# Walking state
			sprint_multiplier_increase = 0
			movement_controller(movement_data.SPEED ,movement_data.ACCELERATION, \
			movement_data.AIR_ACCEL, movement_data.FRICTION, movement_data.AIR_RESISTANCE, delta)
	else:
		velocity = Vector3(0,0,0)
		
	# Sets velocity.y back to vy
	velocity.y = vy


func movement_conditions(delta) -> void:
	'''Makes checks for the sprinting requirements so the player can walk, sprint, or max sprint.
		If it fits any of the requirements, then it will toggle the state on.'''
	# Splits the y velocity from the rest of the velocity.
	var velox = velocity.x
	var veloz = velocity.z
	var velocityxz = Vector3(velox, 0, veloz)
	# Checks if the sprint toggle is enabled
	if GameOptions.sprint_toggle == false:
		# Checks the requirements for if sprinting or max sprinting should be enabled
		if Input.is_action_pressed("sprint") and velocityxz.length() != 0 and \
		velocity.length() < movement_data.MAX_SPRINT_REQUIREMENT and max_sprint <= 0 or \
		is_on_wall():
			# Sprint requirement
			max_sprint = 0
			walking = false
			sprinting = true
			max_sprinting = false
		elif Input.is_action_pressed("sprint") and velocityxz.length() > movement_data.MAX_SPRINT_REQUIREMENT and max_sprint >= 0:
			# Max sprint requirement
			max_sprint = 0.8
			walking = false
			sprinting = false
			max_sprinting = true
		elif velocityxz.length() < movement_data.MAX_SPRINT_REQUIREMENT and max_sprint > 0:
			max_sprint -= delta
		elif not Input.is_action_pressed("sprint"):
			# Walk requirement
			max_sprint = 0
			walking = true
			sprinting = false
			max_sprinting = false
	
#	elif GameOptions.sprint_toggle == true:
#		if Input.is_action_just_pressed("sprint"):
#			if walking == true:
#				sprinting = true
#				walking = false
#			elif sprinting == true or max_sprinting == true:
#				sprinting = false
#				max_sprinting = false
#				walking = true


func movement_controller(speed, acceleration, air_acceleration, friction, air_resistance, delta) -> void:
	'''Checks for any input from the player. Using the input info and the direction that the camera is facing, 
	it calculates the direction that the player should move in.
	Depending on if the character is on the floor, in the air, or stopped inputting, it will apply a different
	velocity to the player.'''
	#checks for input
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	if input_dir != Vector2.ZERO:
#handles the acceleration of the player on ground and air
		if is_on_floor():
			var slope_direction = Vector3(raycast_normal.x, 0, raycast_normal.z).normalized()
			var slope_alignment = direction.dot(slope_direction)
			var slope_angle = 1.0 - raycast_normal.y
			var slope_effect = 0
			if slope_alignment > 0:
				slope_effect = slope_alignment * slope_angle * 50
			else:
				slope_effect = slope_alignment * slope_angle * 30
			
			var adjust_speed = speed + slope_effect
			var target_velocity = direction * adjust_speed
			
			velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
			velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)
		elif not is_on_floor():
			velocity = lerp(velocity, direction * speed, air_acceleration * delta)
#handles the friction of the player on ground and air
	else:
		if is_on_floor():
			velocity = lerp(velocity, direction * 0.0, friction * delta)
			#velocity.z = move_toward(velocity.z, direction * 0.0, friction * delta)
		elif not is_on_floor():
			velocity = lerp(velocity, direction * 0.0, air_resistance * delta)
			#velocity.z = move_toward(velocity.z, direction * 0.0, air_resistance * delta)


func handle_timers(_delta) -> void:
	'''Handles the timers that are used for the player.'''
	pass


func _on_interaction_area_exited(area: Area3D) -> void:
	pass # Replace with function body.
