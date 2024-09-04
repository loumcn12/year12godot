extends Control
var acceleration = false
@onready var fullscreen = $VBoxContainer/WindowButton/CheckButton
@onready var button = $VBoxContainer/Button
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/mainmenu.tscn")


func _on_check_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_button_pressed():
	acceleration = !acceleration
	if acceleration:
		button.text = "Modular Hardware Acceleration: Off"
		$Label.text = "FPS: 30"
	else:
		button.text = "Modular Hardware Acceleration: On "
		$Label.text = "FPS: 300"
		
		
		
