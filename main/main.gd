extends Node3D

enum State { EXPLORING, TYPING, READING }

@export_category("Node References")
@export var _starting_room: Room
@export var _player: Player
@export var _room_scene: PackedScene
@export var _typing_interface: TypingInterface
@export var _reading_interface: ReadingInterface

@export_category("Tweakables")
@export_range(0, 99) var _starting_seed_x: int = 49
@export_range(0, 99) var _starting_seed_y: int = 49

var _player_coordinates: Vector2i
var _current_room: Room
var _fsm_controller: FsmController


func _ready():
	_fsm_controller = FsmController.new()
	_fsm_controller.register_state(State.EXPLORING, _define_exploring_state())
	_fsm_controller.register_state(State.TYPING, _define_typing_state())
	_fsm_controller.switch_state(State.EXPLORING)

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
	_player.allow_input = false

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

	_player.allow_input = true
	next_room.close_opening_after_entering(dir)
	_current_room.queue_free()
	_current_room = next_room


func _define_exploring_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func():
		_player.allow_input = true

	state.add_signal_callback(
		_player.request_interaction,
		func(facing: Constants.CompassDir):
			if _current_room.does_wall_have_door(facing):
				_do_enter_room_sequence(facing)
			else:
				_fsm_controller.switch_state(State.TYPING)
	)

	return state


func _define_typing_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func():
		_player.allow_input = false
		_typing_interface.initialize()

	state.add_signal_callback(
		_typing_interface.finished, func(): _fsm_controller.switch_state(State.EXPLORING)
	)

	return state
