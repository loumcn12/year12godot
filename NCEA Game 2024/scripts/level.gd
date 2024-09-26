extends Node3D

var powerdown = true
@export var wait_time = 12
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.2).timeout
	
	await get_tree().create_timer(wait_time).timeout
	Globalscript.phase = 1
func _togglelight():
	$Enviroment/SpotLight3D.visible = !$Enviroment/SpotLight3D.visible
	$Enviroment/SpotLight3D2.visible = !$Enviroment/SpotLight3D2.visible
	$Enviroment/SpotLight3D4.visible = !$Enviroment/SpotLight3D4.visible
	$Enviroment/SpotLight3D5.visible = !$Enviroment/SpotLight3D5.visible
	$Enviroment/SpotLight3D6.visible = !$Enviroment/SpotLight3D6.visible
func _powerdown():
	
	if powerdown:
		$Enviroment/AudioStreamPlayer3D.play()
		_togglelight()
		powerdown = false
		
func _physics_process(_delta):
	
	if Globalscript.phase == 0:
		$Enviroment/SpotLight3D.visible = true
		$Enviroment/SpotLight3D2.visible = true
		$Enviroment/SpotLight3D4.visible = true
		$Enviroment/SpotLight3D5.visible = true
		$Enviroment/SpotLight3D6.visible = true
	if Globalscript.phase == 1:
		_powerdown()
	if Globalscript.phase == 3:
		$Shed/AudioStreamPlayer3D.play()
		Globalscript.phase = 4
	if Globalscript.phase == 4 and $Shed/AudioStreamPlayer3D.playing == false:
		if $Shed/IdlePlayer.playing == false:
			$Shed/IdlePlayer.play()
		$Enviroment/SpotLight3D.visible = true
		$Enviroment/SpotLight3D2.visible = true
		$Enviroment/SpotLight3D4.visible = true
		$Enviroment/SpotLight3D5.visible = true
		$Enviroment/SpotLight3D6.visible = true
