extends CharacterBody3D

var door_open

func _physics_process(delta):
	if door_open:
		rotation.y = move_toward(rotation.y, deg_to_rad(rotation.y + 120), 0.05)
	elif !door_open:
		rotation.y = move_toward(rotation.y, deg_to_rad(rotation.y - 0), 0.05)
