extends StaticBody3D
#
var door_open = false
@export var door_locked = false

func _ready():
	open_door()
	open_door()
#
#func _physics_process(delta):
	#if door_open and door_moving:
		#rotation.y = move_toward(rotation.y, (rotation.y + deg_to_rad(120)), 0.05)
		#
	#elif !door_open and door_moving:
		#rotation.y = move_toward(rotation.y, (rotation.y - deg_to_rad(120)), 0.05)

func open_door():
	
	if door_open:
		$AnimationPlayer.play_backwards("Door")
	else:
		$AnimationPlayer.play("Door")
	door_open = !door_open
