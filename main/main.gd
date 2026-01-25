extends Node3D

const ROOM_SIZE: float = 5.0

@export var _starting_room: Room
@export var _room_scene: PackedScene
@export_range(0, 99) var _starting_seed_x: int = 49
@export_range(0, 99) var _starting_seed_y: int = 49

var _player_coordinates: Vector2i


func _ready():
	_starting_room.initialize(_get_seed())


func _get_seed() -> int:
	var seed_x = wrapi(_starting_seed_x + _player_coordinates.x, 0, 100)
	var seed_y = wrapi(_starting_seed_y + _player_coordinates.y, 0, 100)
	var combined := str(seed_x) + str(seed_y)
	return int(combined)


func _create_room(coordinates: Vector2) -> Room:
	var new_room := _room_scene.instantiate() as Room
	new_room.global_position.x = coordinates.x * ROOM_SIZE
	new_room.global_position.z = coordinates.y * ROOM_SIZE
	return new_room
