extends Node3D
var phase = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(5).timeout
	$AudioStreamPlayer3D.play()
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
		$AudioStreamPlayer3D4.play()
		$Control/VBoxContainer/Label.text = "Did you board up the windows?"
		await get_tree().create_timer(4).timeout
		$Control.visible = true
		phase = 2
	if ($Control/VBoxContainer/HBoxContainer/Button.button_pressed or $Control/VBoxContainer/HBoxContainer/Button2.button_pressed) and phase == 2:
		$Control.visible = false
		$AudioStreamPlayer3D5.play()
		$Control/VBoxContainer/Label.text = "Did you check the house was empty before you secured it?"
		
		await get_tree().create_timer(4).timeout
		$AudioStreamPlayer3D5.stop()
		$Control.visible = true
		phase = 3
	if $Control/VBoxContainer/HBoxContainer/Button.button_pressed and phase == 3:
			$AudioStreamPlayer3D2.play()
	if $Control/VBoxContainer/HBoxContainer/Button2.button_pressed and phase == 3:
			$Control.visible = false
			await get_tree().create_timer(4).timeout
			$LoadingScreen.visible = true
			$person.visible = true
			await get_tree().create_timer(1).timeout
			$LoadingScreen.visible = false
			await get_tree().create_timer(1).timeout
			$LoadingScreen.visible = true
			$person.visible = false
			await get_tree().create_timer(1).timeout
			$LoadingScreen.visible = false
			await get_tree().create_timer(3).timeout
			$LoadingScreen.visible = true
			$AudioStreamPlayer3D5.play()
			await get_tree().create_timer(5).timeout
			$AudioStreamPlayer3D5.stop()
			$AudioStreamPlayer3D3.play()
			$Jumpscare.visible = true
			await get_tree().create_timer(5).timeout
			$Jumpscare.visible = false
			await get_tree().create_timer(2).timeout
			get_tree().change_scene_to_file("res://Scenes/Menus/mainmenu.tscn")
			
