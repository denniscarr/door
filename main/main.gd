extends Node3D

enum State { EXPLORING, TYPING, PLACING_MESSAGE, READING }

@export_category("Node References")
@export var _starting_room: Room
@export var _player: Player
@export var _movement_interface: MovementInterface
@export var _typing_interface: TypingInterface
@export var _reading_interface: ReadingInterface
@export var _room_scene: PackedScene
@export var _message_helper: MessagePlacementHelper

@export_category("Tweakables")
@export_range(0, 99) var _starting_seed_x: int = 49
@export_range(0, 99) var _starting_seed_y: int = 49

var _player_coordinates: Vector2i
var _current_room: Room
var _fsm_controller: FsmController


func _ready():
	_fsm_controller = FsmController.new()
	_fsm_controller.register_state(State.EXPLORING, _define_exploring_state())
	_fsm_controller.register_state(State.READING, _define_reading_state())
	_fsm_controller.register_state(State.TYPING, _define_typing_state())
	_fsm_controller.register_state(State.PLACING_MESSAGE, _define_placing_message_state())

	_current_room = _starting_room
	_starting_room.initialize(_get_seed())
	_message_helper.set_room(_get_seed())

	_fsm_controller.switch_state(State.EXPLORING)


func _process(delta: float):
	_fsm_controller.process_tick(delta)


func _input(event: InputEvent):
	_fsm_controller.input(event)


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
	_message_helper.set_room(_get_seed())

	await _current_room.do_open_door(dir)

	_player.move_to_next_room()

	await _player.entered_room

	_movement_interface.set_buttons_disabled(false)
	_movement_interface.set_buttons_visible(true)
	CursorManager.set_cursor_active(true)

	_player.allow_input = true
	next_room.close_opening_after_entering(dir)
	_message_helper.delete_messages_in_room(_current_room.rng_seed)
	_current_room.queue_free()
	_current_room = next_room


func _define_exploring_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func():
		_player.allow_input = true
		_movement_interface.set_buttons_visible(true)
		_movement_interface.set_buttons_disabled(false)
		CursorManager.set_cursor_active(true)
		CursorManager.enable_env_highlighting(true)

	state.exit_callback = func():
		_movement_interface.set_buttons_visible(false)
		_movement_interface.set_buttons_disabled(true)

	state.add_signal_callback(
		_player.request_interaction,
		func(facing: Constants.CompassDir):
			if _current_room.does_wall_have_door(facing):
				_movement_interface.set_buttons_disabled(true)
				_movement_interface.set_buttons_visible(false)
				CursorManager.set_cursor_active(false)
				CursorManager.enable_env_highlighting(true)
				_do_enter_room_sequence(facing)
			else:
				_fsm_controller.switch_state(State.TYPING)
	)

	state.add_signal_callback(
		_message_helper.message_opened,
		func(message_text: String):
			_reading_interface.initialize(message_text)
			_fsm_controller.switch_state(State.READING)
	)

	state.add_signal_callback(
		_movement_interface.request_turn_left,
		func():
			_movement_interface.set_buttons_disabled(true)
			CursorManager.set_cursor_active(false)
			CursorManager.enable_env_highlighting(false)
			_player.turn_left()
	)

	state.add_signal_callback(
		_movement_interface.request_turn_right,
		func():
			_movement_interface.set_buttons_disabled(true)
			CursorManager.set_cursor_active(false)
			CursorManager.enable_env_highlighting(false)
			_player.turn_right()
	)

	state.add_signal_callback(
		_player.finished_turning,
		func():
			_movement_interface.set_buttons_disabled(false)
			CursorManager.set_cursor_active(true)
			CursorManager.enable_env_highlighting(true)
	)

	state.add_signal_callback(
		_movement_interface.request_post_message, func(): _fsm_controller.switch_state(State.TYPING)
	)

	return state


func _define_reading_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func():
		_player.allow_input = false
		CursorManager.enable_env_highlighting(false)

	state.add_signal_callback(
		_reading_interface.finished, func(): _fsm_controller.switch_state(State.EXPLORING)
	)

	return state


func _define_typing_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func():
		_player.allow_input = false
		CursorManager.enable_env_highlighting(false)
		_typing_interface.initialize()

	state.add_signal_callback(
		_typing_interface.finished,
		func(typed_text: String):
			_message_helper.begin_placing(typed_text)
			_fsm_controller.switch_state(State.PLACING_MESSAGE)
	)

	return state


func _define_placing_message_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func(): CursorManager.enable_env_highlighting(false)

	state.process_callback = func(_delta: float): _message_helper.update_placing(_player.camera)

	state.input_callback = func(event: InputEvent):
		if not event is InputEventMouseButton:
			return

		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed && _message_helper.try_placing():
			_fsm_controller.switch_state(State.EXPLORING)

	return state
