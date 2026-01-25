extends Node3D

@export var _starting_room: Room
@export var _room_scene: PackedScene
@export var _player: Player
@export_range(0, 99) var _starting_seed_x: int = 49
@export_range(0, 99) var _starting_seed_y: int = 49

var _player_coordinates: Vector2i
var _current_room: Room


func _ready():
	_player.request_move.connect(_on_player_request_move)
	_current_room = _starting_room
	_starting_room.initialize(_get_seed())


func _get_seed() -> int:
	var seed_x = wrapi(_starting_seed_x + _player_coordinates.x, 0, 100)
	var seed_y = wrapi(_starting_seed_y + _player_coordinates.y, 0, 100)
	var combined := str(seed_x) + str(seed_y)
	return int(combined)


func _create_room(coordinates: Vector2) -> Room:
	var new_room := _room_scene.instantiate() as Room
	add_child(new_room)
	new_room.global_position.x = coordinates.x * Constants.ROOM_SIZE
	new_room.global_position.z = coordinates.y * Constants.ROOM_SIZE
	return new_room


func _do_enter_room_sequence(dir: Constants.CompassDir):
	match dir:
		Constants.CompassDir.NORTH:
			_player_coordinates.y -= 1
		Constants.CompassDir.SOUTH:
			_player_coordinates.y += 1
		Constants.CompassDir.EAST:
			_player_coordinates.x += 1
		Constants.CompassDir.WEST:
			_player_coordinates.x -= 1

	var next_room := _create_room(_player_coordinates)
	next_room.initialize(_get_seed())
	next_room.create_opening_for_entering(dir)

	await _current_room.do_open_door(dir)

	_player.move_to_next_room()

	await _player.entered_room

	next_room.close_opening_after_entering(dir)
	_current_room.queue_free()
	_current_room = next_room


func _on_player_request_move(dir: Constants.CompassDir):
	if not _current_room.does_wall_have_door(dir):
		print("You can't move in that direction because there's no door.")
		return

	_do_enter_room_sequence(dir)
