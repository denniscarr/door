class_name MessagePlacementHelper
extends Node3D

@export var _message_scene: PackedScene

var _current_message: Message


func begin_placing():
	_current_message = _message_scene.instantiate() as Message
	add_child(_current_message)


func update_placing(cam: Camera3D):
	var space_state = get_world_3d().direct_space_state
	var mouse_pos := get_viewport().get_mouse_position()
	var origin := cam.project_ray_origin(mouse_pos)
	var end := origin + cam.project_ray_normal(mouse_pos) * 1000.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.collision_mask = 3
	var result := space_state.intersect_ray(query)
	if result:
		if (result.collider as CollisionObject3D).collision_layer == 2:
			_current_message.visible = true
			_current_message.global_position = result.position
			_current_message.look_at(result.position - result.normal)
		else:
			_current_message.visible = false


func try_placing() -> bool:
	if _current_message == null:
		return false

	if not _current_message.visible:
		return false

	_current_message.set_placed("fucky chucky")
	_current_message = null
	return true
