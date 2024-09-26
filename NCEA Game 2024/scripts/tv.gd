extends Node3D

@export var wait_time = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.2).timeout
	$Camera3D.current = true
	$SubViewport/VideoStreamPlayer.play()
	await get_tree().create_timer(10).timeout
	$Camera3D.current = false
	await get_tree().create_timer(wait_time).timeout
	$SubViewport/VideoStreamPlayer.paused = true
	$MeshInstance3D.visible = false
