extends StaticBody3D
#
var door_open = false
@export var door_locked = false

func _ready():
	open_door()
	open_door()

func open_door():
	
	if door_open:
		$AnimationPlayer.play_backwards("Door")
	else:
		$AnimationPlayer.play("Door")
	door_open = !door_open
