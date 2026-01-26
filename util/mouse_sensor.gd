class_name MouseSensor
extends StaticBody3D

var is_mouse_over: bool:
	get: return _is_mouse_over

var _is_mouse_over: bool = false


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered():
	_is_mouse_over = true


func _on_mouse_exited():
	_is_mouse_over = false