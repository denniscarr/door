class_name MessagePlacementHelper
extends Node3D

signal message_opened(message_text: String)

@export var _message_scene: PackedScene

var _current_message: Message
var _room_seed: int
var _message_infos_by_room_seed: Dictionary[int, Array]
var _extant_messages_by_room_seed: Dictionary[int, Array]


func set_room(room_seed: int):
	_room_seed = room_seed


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

	# Place the message
	_current_message.set_placed("fucky chucky")
	_current_message.opened.connect(_on_message_opened)

	# Store a reference to this message
	if not _extant_messages_by_room_seed.has(_room_seed):
		_extant_messages_by_room_seed[_room_seed] = []
	_extant_messages_by_room_seed[_room_seed].push_back(_current_message)

	# Store message info for next time we enter this room
	var message_info := PlacedMessageInfo.new()
	message_info.text = "fucky chucky"
	message_info.position = _current_message.global_position
	message_info.rotation = _current_message.global_rotation
	if not _message_infos_by_room_seed.has(_room_seed):
		_message_infos_by_room_seed[_room_seed] = []
	_message_infos_by_room_seed[_room_seed].push_back(message_info)

	_current_message = null
	return true


func _on_message_opened(message_text: String):
	message_opened.emit(message_text)


class PlacedMessageInfo:
	var text: String
	var position: Vector3
	var rotation: Vector3