extends CharacterBody3D

# Player nodes
@onready var player = $"."
@onready var neck = $neck
@onready var head = $neck/Head
@onready var eyes = $neck/Head/eyes
@onready var camera_3d = $neck/Head/eyes/Camera3D
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var uncrouch_check = $uncrouch_check
@onready var ray = $neck/Head/eyes/Camera3D/interaction_check
@onready var interaction_notifier = $Control/interaction_notifier
@onready var gascan_notifier = $Control/gascan_notifier
@onready var locked_door = $Control/locked_door
@onready var lock_door = $Control/lock_door
@onready var unlock_door = $Control/unlock_door

# Speed variables
var current_speed = 5.0
@export var walking_speed = 5.0
@export var crouching_speed = 3.0

# States
var walking = false
var crouching = false
var sliding = false
var can_doublejump = true

# Head bobbing vars
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0
var head_bobbing_walking_intensity = 0.1
var head_bobbing_crouching_intensity = 0.05
var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# Modifiers
@export var jump_velocity = 4.5
var lerp_speed = 10.0
var crouching_depth = -0.5
var player_height = 1.8

# Input variables
var direction = Vector3.ZERO
@export var mouse_sens = 0.25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	# Make the mouse cursor invisible and locked to the centre of the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	# Make the camera movement match mouse movement
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _check_ray_hit():
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider:
			if collider.is_in_group("door") and !collider.door_locked:
				interaction_notifier.visible = true
				
				if Input.is_action_just_pressed("use") :
					collider.open_door()
			elif collider.is_in_group("door") and collider.door_locked:
				locked_door.visible = true
			elif collider.is_in_group("gascan"):
				gascan_notifier.visible = true
				
				if Input.is_action_just_pressed("use"):
					$gascan.visible = true
					collider.queue_free()
	
	else:
		interaction_notifier.visible = false
		gascan_notifier.visible = false
		locked_door.visible = false
		lock_door.visible = false
		unlock_door.visible = false

func _physics_process(delta):
	_check_ray_hit()
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
			
	# Handle crouching
	if (Input.is_action_pressed("crouch") && is_on_floor()) || sliding:
		# Crouching	
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		head.position.y = lerp(head.position.y,player_height -1.8 + crouching_depth,delta*lerp_speed)	
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
			
		walking = false
		crouching = true
	elif !uncrouch_check.is_colliding():	
		# Standing	
		head.position.y = lerp(head.position.y,player_height - 1.8,delta*lerp_speed)
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true	
	
		current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)	
		walking = true
		crouching = false	
	

	# Handle headbob
	if walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
		
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity,delta*lerp_speed)
	else:
		eyes.position.y = lerp(eyes.position.y, 0.0,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0,delta*lerp_speed)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !uncrouch_check.is_colliding():
		velocity.y = jump_velocity
		sliding = false

	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
				
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# Reset the scene if prompted or if player falls out of world
	if player.position.y < -10 || Input.is_physical_key_pressed(KEY_R):
		get_tree().reload_current_scene()
	
	# Quits the game if the escape key is pressed
	if Input.is_physical_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	move_and_slide()
