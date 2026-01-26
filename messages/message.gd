class_name Message
extends Node3D

signal opened(message_text: String)

@export var _mesh_instance: MeshInstance3D
@export var _body: StaticBody3D
@export var _shape: CollisionShape3D

var message_text: String:
	get:
		return _message_text

var _is_highlighted: bool = false
var _message_text: String = ""


func _input(event: InputEvent):
	if not _is_highlighted:
		return

	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton
	if mouse_event.pressed:
		opened.emit(_message_text)


func set_text(message_text: String):
	_message_text = message_text


func set_placed():
	_shape.disabled = false
	_body.mouse_entered.connect(_on_body_mouse_entered)
	_body.mouse_exited.connect(_on_body_mouse_exited)


func _highlight():
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	mat.emission_energy_multiplier = 0.4
	_is_highlighted = true


func _unhighlight():
	var mat := _mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	mat.emission_energy_multiplier = 0.2
	_is_highlighted = false


func _on_body_mouse_entered():
	_highlight()


func _on_body_mouse_exited():
	_unhighlight()
