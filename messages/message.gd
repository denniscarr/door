class_name Message
extends Node3D

signal opened(message_text: String)

@export var _mesh_instance: MeshInstance3D
@export var _mouse_sensor: MouseSensor
@export var _shape: CollisionShape3D

var message_text: String:
	get:
		return _message_text

var _message_text: String = ""


func _input(event: InputEvent):
	if not (CursorManager.cursor_active and _mouse_sensor.is_mouse_over):
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
	_mouse_sensor.highlight.connect(_on_mouse_sensor_highlight)
	_mouse_sensor.unhighlight.connect(_on_mouse_sensor_unhighlight)


func _on_mouse_sensor_highlight():
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	mat.emission_energy_multiplier = 0.4


func _on_mouse_sensor_unhighlight():
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	mat.emission_energy_multiplier = 0.2


func _on_body_mouse_entered():
	if CursorManager.env_highlighting:
		_on_mouse_sensor_highlight()


func _on_body_mouse_exited():
	_on_mouse_sensor_unhighlight()
