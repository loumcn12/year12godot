extends Node3D

@export var wait_time = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.2).timeout
	$SubViewport/VideoStreamPlayer.play()
	await get_tree().create_timer(wait_time).timeout
	$SubViewport/VideoStreamPlayer.paused = true
	$MeshInstance3D.visible = false
