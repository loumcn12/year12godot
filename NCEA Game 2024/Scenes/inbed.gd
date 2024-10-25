extends Node3D
var phase = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	await get_tree().create_timer(5).timeout
	$Enviroment/AudioStreamPlayer3D.play()
	$Enviroment/SpotLight3D.visible = false
	$Enviroment/SpotLight3D2.visible = false
	$Enviroment/SpotLight3D4.visible = false
	$Enviroment/SpotLight3D5.visible = false
	await get_tree().create_timer(3).timeout
	phase = 1
	$Control.visible = true
	
				
func _physics_process(_delta):
	if ($Control/VBoxContainer/HBoxContainer/Button.button_pressed or $Control/VBoxContainer/HBoxContainer/Button2.button_pressed) and phase == 1:
		$Control.visible = false
		$Control/VBoxContainer/Label.text = "Did you board up the windows?"
		await get_tree().create_timer(3).timeout
		$Control.visible = true
		phase = 2
	if ($Control/VBoxContainer/HBoxContainer/Button.button_pressed or $Control/VBoxContainer/HBoxContainer/Button2.button_pressed) and phase == 2:
		$Control.visible = false
		$Control/VBoxContainer/Label.text = "Did you check the house was empty before you secured it?"
		
		await get_tree().create_timer(3).timeout
		$Control.visible = true
		phase = 3
	if $Control/VBoxContainer/HBoxContainer/Button.button_pressed and phase == 3:
			$AudioStreamPlayer3D2.play()
	if $Control/VBoxContainer/HBoxContainer/Button2.button_pressed and phase == 3:
			$Control.visible = false
