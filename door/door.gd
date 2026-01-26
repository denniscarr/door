class_name Door
extends Node3D

@export var _hinge: Node3D
@export var _shape: CollisionShape3D
@export var _mouse_sensor: MouseSensor
@export var _highlight_meshes: Array[MeshInstance3D]


func _input(event: InputEvent):
	if not (CursorManager.cursor_active and _mouse_sensor.is_mouse_over):
		return

	if not event is InputEventMouseButton:
		return

	var mouse_event := event as InputEventMouseButton
	if _mouse_sensor.is_mouse_over and mouse_event.pressed:
		GlobalSignals.request_door_open.emit()


func set_active(active: bool):
	visible = active
	_shape.disabled = !active

	if active:
		_mouse_sensor.highlight.connect(_on_mouse_sensor_highlight)
		_mouse_sensor.unhighlight.connect(_on_mouse_sensor_unhighlight)
	else:
		if _mouse_sensor.highlight.is_connected(_on_mouse_sensor_highlight):
			_mouse_sensor.highlight.disconnect(_on_mouse_sensor_highlight)
		if _mouse_sensor.unhighlight.is_connected(_on_mouse_sensor_unhighlight):
			_mouse_sensor.unhighlight.disconnect(_on_mouse_sensor_unhighlight)


func do_open():
	var open_tween := create_tween()
	var target_rotation := Vector3(0.0, 120.0, 0.0)
	open_tween.tween_property(_hinge, "rotation_degrees", target_rotation, 1.0)
	await open_tween.finished


func _on_mouse_sensor_highlight():
	CursorManager.is_highlighting_door = true
	for mesh: MeshInstance3D in _highlight_meshes:
		if mesh.get_surface_override_material_count() < 1:
			continue
		var mat := mesh.get_surface_override_material(0) as StandardMaterial3D
		mat.emission_enabled = true
		mat.emission = Color.BISQUE
		mat.emission_energy_multiplier = 0.05


func _on_mouse_sensor_unhighlight():
	CursorManager.is_highlighting_door = false
	for mesh: MeshInstance3D in _highlight_meshes:
		if mesh.get_surface_override_material_count() < 1:
			continue
		var mat := mesh.get_surface_override_material(0) as StandardMaterial3D
		mat.emission_enabled = false
