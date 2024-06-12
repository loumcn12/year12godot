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

# Speed variables
var current_speed = 5.0
@export var walking_speed = 5.0
@export var sprinting_speed = 8.0
@export var crouching_speed = 3.0

# States

var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false
var can_doublejump = true

# Slide vars

var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0
var base_slide_cooldown = 3
var slide_cooldown = 1
var can_slide = true

# Head bobbing vars

const head_bobbing_sprinting_speed = 22.0
const head_bobbing_walking_speed = 14.0
const head_bobbing_crouching_speed = 10.0

var head_bobbing_sprinting_intensity = 0.2
var head_bobbing_walking_intensity = 0.1
var head_bobbing_crouching_intensity = 0.05

var head_bobbing_vector = Vector2.ZERO
var head_bobbing_index = 0.0
var head_bobbing_current_intensity = 0.0

# Dimension variables
@export var jump_velocity = 4.5
var lerp_speed = 10.0
var air_lerp_speed = 3.0
var crouching_depth = -0.5
var player_height = 1.8
var free_look_tilt_amount = 5.0

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
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y, deg_to_rad(-120), deg_to_rad(120))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _physics_process(delta):
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if Input.is_physical_key_pressed(KEY_L):
		position.y = lerp(position.y, position.y + 0.5, delta*lerp_speed)	
		
	
	# Handle crouching and sprinting
	if (Input.is_action_pressed("crouch") && is_on_floor()) || sliding:
		
		# Crouching
		
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		head.position.y = lerp(head.position.y,player_height -1.8 + crouching_depth,delta*lerp_speed)
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		# Slide begin logic
		if sprinting && input_dir != Vector2.ZERO && is_on_floor() && can_slide:
			sliding = true
			free_looking = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			can_slide = false
			slide_cooldown = base_slide_cooldown
			
		
		walking = false
		sprinting = false
		crouching = true
		
	elif !uncrouch_check.is_colliding():
		
		# Standing
		
		head.position.y = lerp(head.position.y,player_height - 1.8,delta*lerp_speed)
		
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		if Input.is_action_pressed("sprint"):
			
			# Sprinting
			
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
			
			walking = false
			sprinting = true
			crouching = false
		else:
			
			# Walking
			
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
			
			walking = true
			sprinting = false
			crouching = false
			
	# Handle free looking
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		if sliding:
			camera_3d.rotation.z = lerp(camera_3d.rotation.z,-deg_to_rad(7.0), delta * lerp_speed)
		else:
			camera_3d.rotation.z = deg_to_rad(-neck.rotation.y*free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, delta * lerp_speed)
		
	# Handle sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false
	
	# Handle slide cooldown
	if !can_slide:
		slide_cooldown -= delta
		if slide_cooldown <= 0:
			can_slide = true
	
	# Handle headbob
	if sprinting:
		head_bobbing_current_intensity = head_bobbing_sprinting_intensity
		head_bobbing_index += head_bobbing_sprinting_speed * delta
	elif walking:
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
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false
		
	if Input.is_physical_key_pressed(KEY_SPACE) and !is_on_floor() && can_doublejump:
		position.y = lerp(position.y, position.y + 0.5, delta*lerp_speed)

	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*air_lerp_speed)
		
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer+0.1) * slide_speed
		
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
