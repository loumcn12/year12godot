extends Control


# Called when the node enters the scene tree for the first time.


func _on_start_button_pressed():
	$AudioStreamPlayer2D.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/level.tscn")


func _on_options_button_pressed():
	$AudioStreamPlayer2D.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/Menus/menu_options.tscn")


func _on_quit_button_pressed():
	$AudioStreamPlayer2D.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
