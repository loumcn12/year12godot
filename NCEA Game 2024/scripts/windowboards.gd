extends StaticBody3D

@onready var windowboards2 = $Area3D/windowboards


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	windowboards2.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
