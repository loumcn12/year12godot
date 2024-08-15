extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/menu_options.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
