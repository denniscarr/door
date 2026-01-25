class_name Player
extends Node3D

signal request_move(dir: Constants.CompassDir)
signal entered_room

enum State {
	IDLE,
	TURNING_LEFT,
	TURNING_RIGHT,
	MOVING_FORWARD,
}

var allow_input: bool = true

var _current_compass_dir: Constants.CompassDir = Constants.CompassDir.NORTH
var _fsm_controller: FsmController


func _ready():
	_fsm_controller = FsmController.new()
	_fsm_controller.register_state(State.IDLE, _define_idle_state())
	_fsm_controller.register_state(State.TURNING_LEFT, _define_turning_left_state())
	_fsm_controller.register_state(State.TURNING_RIGHT, _define_turning_right_state())
	_fsm_controller.register_state(State.MOVING_FORWARD, _define_moving_forward_state())
	_fsm_controller.switch_state(State.IDLE)


func _input(event: InputEvent):
	_fsm_controller.input(event)


func move_to_next_room():
	_fsm_controller.switch_state(State.MOVING_FORWARD)


func _create_turning_tween(target_angle: float) -> Tween:
	var tween := create_tween()
	var target_rotation = Vector3(0.0, target_angle, 0.0)
	tween.tween_property(self, "rotation_degrees", target_rotation, 1.0)
	return tween


func _define_idle_state() -> FsmState:
	var state := FsmState.new()

	state.input_callback = func(event: InputEvent):
		if event.is_action_pressed("turn_left"):
			_fsm_controller.switch_state(State.TURNING_LEFT)
		elif event.is_action_pressed("turn_right"):
			_fsm_controller.switch_state(State.TURNING_RIGHT)
		elif event.is_action_pressed("move_forward"):
			request_move.emit(_current_compass_dir)

	return state


func _define_turning_left_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func():
		match _current_compass_dir:
			Constants.CompassDir.NORTH:
				_current_compass_dir = Constants.CompassDir.WEST
			Constants.CompassDir.WEST:
				_current_compass_dir = Constants.CompassDir.SOUTH
			Constants.CompassDir.SOUTH:
				_current_compass_dir = Constants.CompassDir.EAST
			Constants.CompassDir.EAST:
				_current_compass_dir = Constants.CompassDir.NORTH

		var tween := _create_turning_tween(rotation_degrees.y + 90.0)
		tween.tween_callback(_fsm_controller.switch_state.bind(State.IDLE))

	return state


func _define_turning_right_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func():
		match _current_compass_dir:
			Constants.CompassDir.NORTH:
				_current_compass_dir = Constants.CompassDir.EAST
			Constants.CompassDir.EAST:
				_current_compass_dir = Constants.CompassDir.SOUTH
			Constants.CompassDir.SOUTH:
				_current_compass_dir = Constants.CompassDir.WEST
			Constants.CompassDir.WEST:
				_current_compass_dir = Constants.CompassDir.NORTH

		var tween := _create_turning_tween(rotation_degrees.y - 90.0)
		tween.tween_callback(_fsm_controller.switch_state.bind(State.IDLE))

	return state


func _define_moving_forward_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func():
		var target_pos := global_position
		target_pos += -transform.basis.z * Constants.ROOM_SIZE
		var move_tween := create_tween()
		move_tween.tween_property(self, "global_position", target_pos, 5.0)
		move_tween.tween_callback(_fsm_controller.switch_state.bind(State.IDLE))

	state.exit_callback = func():
		entered_room.emit()

	return state
