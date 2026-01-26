class_name Message
extends Node3D

signal opened(message_text: String)

@export var _mesh_instance: MeshInstance3D
@export var _mouse_sensor: MouseSensor
@export var _shape: CollisionShape3D

var message_text: String:
	get:
		return _message_text

var _is_highlighted: bool = false
var _message_text: String = ""


func _process(_delta: float):
	if _is_highlighted:
		if not CursorManager.env_highlighting:
			_unhighlight()
			return
		if not _mouse_sensor.is_mouse_over:
			_unhighlight()
			return

	if not _is_highlighted:
		if not CursorManager.env_highlighting:
			return

		if _mouse_sensor.is_mouse_over:
			_highlight()


func _input(event: InputEvent):
	if not _is_highlighted:
		return

	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.pressed:
		opened.emit(_message_text)


func set_text(p_message_text: String):
	_message_text = p_message_text


func set_placed():
	_shape.disabled = false


func _highlight():
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	mat.emission_energy_multiplier = 0.4
	_is_highlighted = true


func _unhighlight():
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	mat.emission_energy_multiplier = 0.2
	_is_highlighted = false


func _on_body_mouse_entered():
	if CursorManager.env_highlighting:
		_highlight()


func _on_body_mouse_exited():
	_unhighlight()
