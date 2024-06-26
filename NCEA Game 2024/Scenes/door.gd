extends CharacterBody3D

var door_open = false
var door_moving = false

func _physics_process(delta):
	if door_open and door_moving:
		rotation.y = move_toward(rotation.y, (rotation.y + deg_to_rad(120)), 0.05)
		if rotation.y == deg_to_rad(0) or deg_to_rad(90) or deg_to_rad(180) or deg_to_rad(270):
			door_moving = false
		
	elif !door_open and door_moving:
		rotation.y = move_toward(rotation.y, (rotation.y - deg_to_rad(120)), 0.05)
		if rotation.y == deg_to_rad(0) or deg_to_rad(90) or deg_to_rad(180) or deg_to_rad(270):
			door_moving = false
