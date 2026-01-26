class_name Door
extends Node3D

@export var _hinge: Node3D
@export var _shape: CollisionShape3D
@export var _mouse_sensor: MouseSensor
@export var _highlight_meshes: Array[MeshInstance3D]


func set_active(active: bool):
	visible = active
	_shape.disabled = !active

	if active:
		_mouse_sensor.highlight.connect(_on_mouse_sensor_highlight)
		_mouse_sensor.unhighlight.connect(_on_mouse_sensor_unhighlight)
	else:
		_mouse_sensor.highlight.disconnect(_on_mouse_sensor_highlight)
		_mouse_sensor.unhighlight.disconnect(_on_mouse_sensor_unhighlight)


func do_open():
	var open_tween := create_tween()
	var target_rotation := Vector3(0.0, 120.0, 0.0)
	open_tween.tween_property(_hinge, "rotation_degrees", target_rotation, 1.0)
	await open_tween.finished


func _on_mouse_sensor_highlight():
	for mesh: MeshInstance3D in _highlight_meshes:
		if mesh.get_surface_override_material_count() < 1:
			continue
		var mat := mesh.get_surface_override_material(0) as StandardMaterial3D
		mat.emission_enabled = true
		mat.emission_energy_multiplier = 0.1


func _on_mouse_sensor_unhighlight():
	for mesh: MeshInstance3D in _highlight_meshes:
		if mesh.get_surface_override_material_count() < 1:
			continue
		var mat := mesh.get_surface_override_material(0) as StandardMaterial3D
		mat.emission_enabled = false
