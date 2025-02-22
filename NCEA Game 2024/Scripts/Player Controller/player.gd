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
@onready var longray = $neck/Head/eyes/Camera3D/interaction_check2
@onready var interaction_notifier = $Control/interaction_notifier
@onready var interaction_notifier2 = $Control/interaction_notifier2
@onready var gascan_notifier = $Control/gascan_notifier
@onready var fueltank_notifier = $Control/fueltank_notifier
@onready var locked_door = $Control/locked_door
@onready var lock_door = $Control/lock_door
@onready var unlock_door = $Control/unlock_door
@onready var torchlight = $neck/Head/eyes/SpotLight3D
@onready var torch = $neck/Head/eyes/torch
@onready var torchnotifier = $Control/torchnotifier
@onready var jumpscare = $Jumpscare
@onready var jumpscareplayer = $JumpscarePlayer

# Speed variables
var current_speed = 2.0
@export var walking_speed = 2.0
@export var crouching_speed = 2.0


# States
var currentlywalking = false
var walking = false
@export var can_move = false
@export var crouching = false
var sliding = false
var can_doublejump = true
var holding_gascan = false
var holding_torch = false
@export var torch_on = false
var scared = false
var doorsclosed = false




# Head bobbing vars
const head_bobbing_walking_speed = 5
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

var gascount = 0


func _ready():
	# Make the mouse cursor invisible and locked to the centre of the screen
	$LoadingLabel.visible = true
	$LoadingScreen.visible = true
	torchlight.visible = torch_on
	var os = OS.get_model_name()
	if os != "Web":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	
		
	await get_tree().create_timer(1.2).timeout
	$LoadingLabel.visible = false
	$LoadingScreen.visible = false
	camera_3d.current = false
	await get_tree().create_timer(10).timeout
	camera_3d.current = true
	await get_tree().create_timer(5).timeout
	can_move = true
	$Objective/gascounter.text = "Current Objective: Find the fuel canisters ( " + str(gascount) + "/5)"
	
		
func _input(event):
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Make the camera movement match mouse movement
	if event is InputEventMouseMotion and can_move:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))

func _jumpscare():
	jumpscareplayer.play()
	jumpscare.visible = true
	if jumpscareplayer.playing == false:
		jumpscare.visible = false
	$Objective/getinhouse.visible = true
	Globalscript.phase = 6
	await get_tree().create_timer(5).timeout
	scared = false
	
	

func _check_ray_hit():
	if longray.is_colliding():
		var collider2 = longray.get_collider()
		if collider2:
			if collider2.is_in_group("enemy") or collider2.is_in_group("enemy2") and Globalscript.phase == 5:
				if scared == false:
					scared = true
					_jumpscare()
					await get_tree().create_timer(0.5).timeout
					jumpscare.visible = false
			
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider:
				
				
			if collider.is_in_group("bed") or collider.is_in_group("bed2") :
				$Control/getinbed.visible = true
	
				if Input.is_action_just_pressed("use"):
					
					get_tree().change_scene_to_file("res://Scenes/inbed.tscn")
				
			if collider.is_in_group("windowboards") and Globalscript.phase == 7:
				$Control/boardwindows.visible = true
				if Input.is_action_just_pressed("use"):
					collider.windowboards2.visible = true
					Globalscript.phase = 8
			
			if collider.is_in_group("door"):
				if Globalscript.phase == 6:
					if collider.is_in_group("house"):
						if collider.door_open == false and Globalscript.phase < 9:
								interaction_notifier.visible = true
								if Input.is_action_just_pressed("use"):
									collider.open_door()
									$Objective/getinhouse.visible = false
									$Objective/securehouse.visible = true
									Globalscript.phase = 7

				else:
					if !collider.door_locked and holding_torch:
						interaction_notifier.visible = true
						
						if Input.is_action_just_pressed("use"):
							collider.open_door()
					elif collider.door_locked:
						locked_door.visible = true
						if Input.is_action_just_pressed("use"):
							$ErrorPlayer.play()
					elif holding_torch == false:
						interaction_notifier2.visible = true
						if Input.is_action_just_pressed("use"):
							$ErrorPlayer.play()
			
			elif collider.is_in_group("gascan") and !holding_gascan and $Objective/generatorobjective.visible == false:
				gascan_notifier.visible = true
				
				if Input.is_action_just_pressed("use"):
					holding_gascan = true
					collider.queue_free()
			elif collider.is_in_group("gascan") and !holding_gascan and $Objective/generatorobjective.visible == true:
				$Control/interaction_notifier3.visible = true
					
			elif collider.is_in_group("fueltank") and holding_gascan:
				fueltank_notifier.visible = true
				
				if Input.is_action_just_pressed("use"):
					holding_gascan = false
					fueltank_notifier.visible = false
					gascount = gascount + 1
					$Objective/gascounter.text = "Current Objective: Find the fuel canisters (" + str(gascount) + "/5)"
					if gascount == 5:
						
						Globalscript.phase = 2
			elif collider.is_in_group("torch"):
				torchnotifier.visible = true
				
				if Input.is_action_just_pressed("use"):
					holding_torch = true
					torchnotifier.visible = false
					collider.queue_free()
			elif collider.is_in_group("startbutton") and Globalscript.phase == 1:
				$Control/startbuttonnotifier.visible = true
				if Input.is_action_just_pressed("use"):
					$Objective/generatorobjective.visible = false
					$Objective/gascounter.visible = true
					$ErrorPlayer.play()
			elif collider.is_in_group("startbutton") and Globalscript.phase == 2:
				$Control/startbuttonnotifier.visible = true
				
				if Input.is_action_just_pressed("use"):
					
					$Objective/gascounter.visible = false
					Globalscript.phase = 3
			else:
				interaction_notifier2.visible = false
				fueltank_notifier.visible = false
				gascan_notifier.visible = false
				locked_door.visible = false
				interaction_notifier.visible = false
				torchnotifier.visible = false
				$Control/startbuttonnotifier.visible = false
				$Control/interaction_notifier3.visible = false
				#$Control/boardwindows.visible = false
				#$Control/boarddoors.visible = false
	
	else:
		interaction_notifier2.visible = false
		interaction_notifier.visible = false
		fueltank_notifier.visible = false
		gascan_notifier.visible = false
		locked_door.visible = false
		lock_door.visible = false
		unlock_door.visible = false
		torchnotifier.visible = false
		$Control/startbuttonnotifier.visible = false
		$Control/interaction_notifier3.visible = false
		$Control/boardwindows.visible = false
		$Control/boarddoors.visible = false

func _walkSound():
	
	if Input.is_action_pressed("backward") or Input.is_action_pressed("forward") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		currentlywalking = true
	else:
		currentlywalking = false
	if currentlywalking and can_move and $WalkingPlayer.playing == false:
		$WalkingPlayer.play()
	elif !currentlywalking:
		$WalkingPlayer.stop()
		

		
func _physics_process(delta):
	
	if Globalscript.phase == 9:
		$Objective/securehouse.visible = false
		$Objective/getinbed.visible = true
		
	if $AudioStreamPlayer.playing == false:
		$AudioStreamPlayer.play()
	if Globalscript.startdone == true and $Objective/gascounter.visible == false and Globalscript.phase == 1:
		$Objective/generatorobjective.visible = true
	_walkSound()
	_check_ray_hit()
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	
	if Input.is_action_just_pressed("torch") and holding_torch:
		torch_on = !torch_on
		torchlight.visible = torch_on
		$neck/Head/eyes/torch/AudioStreamPlayer.play()
	
	if holding_gascan:
		$gascan.visible = true
	else:
		$gascan.visible = false
		
	if holding_torch:
		torch.visible = true
	else:
		torch.visible = false
	# Handle crouching
	if (Input.is_action_pressed("crouch") && is_on_floor()) and can_move:
		crouching = true
	elif !uncrouch_check.is_colliding() and can_move:	
		# Standing	
		head.position.y = lerp(head.position.y,player_height - 1.8,delta*lerp_speed)
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true	
	
		current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)	
		walking = true
		crouching = false	
		
	if crouching:
		# Crouching	
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		head.position.y = lerp(head.position.y,player_height -1.8 + crouching_depth,delta*lerp_speed)	
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
			
		walking = false
	
	

	# Handle headbob
	if walking:
		head_bobbing_current_intensity = head_bobbing_walking_intensity
		head_bobbing_index += head_bobbing_walking_speed * delta
	elif crouching:
		head_bobbing_current_intensity = head_bobbing_crouching_intensity
		head_bobbing_index += head_bobbing_crouching_speed * delta
		
	if is_on_floor() && !sliding && input_dir != Vector2.ZERO && can_move:
		head_bobbing_vector.y = sin(head_bobbing_index)
		head_bobbing_vector.x = sin(head_bobbing_index/2)+0.5
		
		eyes.position.y = lerp(eyes.position.y, head_bobbing_vector.y*(head_bobbing_current_intensity/2.0),delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, head_bobbing_vector.x*head_bobbing_current_intensity,delta*lerp_speed)
	elif can_move:
		eyes.position.y = lerp(eyes.position.y, 0.0,delta*lerp_speed)
		eyes.position.x = lerp(eyes.position.x, 0.0,delta*lerp_speed)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !uncrouch_check.is_colliding() and can_move:
		velocity.y = jump_velocity
		sliding = false

	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	else:
		if input_dir != Vector2.ZERO:
			direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
				
	if direction and can_move:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	# Reset the scene if prompted or if player falls out of world
	if player.position.y < -10:
		get_tree().reload_current_scene()

	
	move_and_slide()



	pass # Replace with function body.
