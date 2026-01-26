class_name MouseSensor
extends StaticBody3D

signal highlight
signal unhighlight

var is_mouse_over: bool:
	get:
		return _is_mouse_over

var _is_mouse_over: bool = false
var _is_highlighted: bool = false


func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _process(_delta: float) -> void:
	if _is_highlighted:
		if not CursorManager.env_highlighting:
			_is_highlighted = false
			unhighlight.emit()
			return
		if not is_mouse_over:
			_is_highlighted = false
			unhighlight.emit()
			return

	if not _is_highlighted:
		if not CursorManager.env_highlighting:
			return

		if is_mouse_over:
			_is_highlighted = true
			highlight.emit()


func _on_mouse_entered():
	_is_mouse_over = true


func _on_mouse_exited():
	_is_mouse_over = false
