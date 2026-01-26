class_name Message
extends Node3D

signal opened(message_text: String)

@export var _mesh_instance: MeshInstance3D
@export var _mouse_sensor: MouseSensor
@export var _shape: CollisionShape3D

var message_text: String:
	get:
		return _message_text

var non_placable: bool:
	get:
		return _non_placable

var _message_text: String = ""
var _non_placable: bool = false


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


func set_non_placable(p_non_placable: bool):
	if _non_placable == p_non_placable:
		return

	_non_placable = p_non_placable

	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	if non_placable:
		mat.albedo_color.a = 0.25
	else:
		mat.albedo_color.a = 1.0


func _on_mouse_sensor_highlight():
	CursorManager.is_highlighting_message = true
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	mat.emission_energy_multiplier = 0.4


func _on_mouse_sensor_unhighlight():
	CursorManager.is_highlighting_message = false
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	mat.emission_energy_multiplier = 0.2


func _on_body_mouse_entered():
	if CursorManager.env_highlighting:
		_on_mouse_sensor_highlight()


func _on_body_mouse_exited():
	_on_mouse_sensor_unhighlight()
