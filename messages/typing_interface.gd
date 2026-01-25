class_name TypingInterface
extends Control

enum State { CLOSED, TYPING, FINISHED }

const _CHARS_BY_KEYCODE: Dictionary[Key, String] = {
	KEY_A: "a",
	KEY_B: "b",
	KEY_C: "c",
	KEY_D: "d",
	KEY_E: "e",
	KEY_F: "f",
	KEY_G: "g",
	KEY_H: "h",
	KEY_I: "i",
	KEY_J: "j",
	KEY_K: "k",
	KEY_L: "l",
	KEY_M: "m",
	KEY_N: "n",
	KEY_O: "o",
	KEY_P: "p",
	KEY_Q: "q",
	KEY_R: "r",
	KEY_S: "s",
	KEY_T: "t",
	KEY_U: "u",
	KEY_V: "v",
	KEY_W: "w",
	KEY_X: "x",
	KEY_Y: "y",
	KEY_Z: "z",
	KEY_SPACE: " ",
	KEY_1: "!",
	KEY_COMMA: ",",
	KEY_SLASH: "?",
	KEY_PERIOD: ".",
	KEY_APOSTROPHE: "'",
}

@export_category("Node References")
@export var _input_label: Label
@export var _timer_label: Label
@export var _char_count_label: Label
@export var _note_panel: PanelContainer
@export var _done_button: Button
@export var _submit_button: Button

@export_category("Tweakables")
@export var _max_chars: int = 99
@export var _max_secs: float = 15.99

var _time_remaining: float
var _chars_typed: int
var _error_tween: Tween
var _fsm_controller: FsmController


func _ready():
	_fsm_controller = FsmController.new()
	_fsm_controller.register_state(State.CLOSED, _define_closed_state())
	_fsm_controller.register_state(State.TYPING, _define_typing_state())
	_fsm_controller.register_state(State.FINISHED, _define_finished_state())

	initialize()


func _process(delta: float):
	_fsm_controller.process_tick(delta)


func _input(event: InputEvent):
	_fsm_controller.input(event)


func initialize():
	_input_label.text = ""

	_time_remaining = _max_secs
	_refresh_timer_label()

	_chars_typed = 0
	_refresh_char_count_label()

	_fsm_controller.switch_state(State.TYPING)


func _add_typed_char(typed_char: String):
	var is_capital := _chars_typed == 0
	if is_capital:
		typed_char = typed_char.to_upper()

	_input_label.text += typed_char
	_chars_typed += 1
	_chars_typed = mini(_chars_typed, _max_chars)
	_refresh_char_count_label()


func _refresh_timer_label():
	_timer_label.text = "Time Left: %s" % floori(_time_remaining)


func _refresh_char_count_label():
	_char_count_label.text = "%s/%s" % [_chars_typed, _max_chars]


func _do_error_anim():
	if _error_tween:
		_error_tween.kill()

	_error_tween = create_tween()
	_error_tween.set_loops(5)
	_error_tween.tween_property(_note_panel, "rotation_degrees", -10.0, 0.01)
	_error_tween.tween_property(_note_panel, "rotation_degrees", 10.0, 0.02)
	_error_tween.tween_property(_note_panel, "rotation_degrees", 0.0, 0.01)


func _define_closed_state() -> FsmState:
	var state := FsmState.new()
	return state


func _define_typing_state() -> FsmState:
	var state := FsmState.new()

	state.process_callback = func(delta: float):
		if _chars_typed > 0:
			_time_remaining -= delta
			_time_remaining = max(_time_remaining, 0.0)
			_refresh_timer_label()
			if _time_remaining <= 0.0:
				_fsm_controller.switch_state(State.FINISHED)

	state.input_callback = func(event: InputEvent):
		if not event.is_pressed():
			return

		if not event is InputEventKey:
			return

		var key_event = event as InputEventKey

		if _CHARS_BY_KEYCODE.has(key_event.keycode):
			_add_typed_char(_CHARS_BY_KEYCODE[key_event.keycode])
		elif key_event.keycode == KEY_BACKSPACE || key_event.keycode == KEY_DELETE:
			_do_error_anim()

		print(_chars_typed)
		if _chars_typed >= 1 and _done_button.visible == false:
			_done_button.visible = true

		if _chars_typed >= _max_chars:
			_fsm_controller.switch_state(State.FINISHED)

	state.add_signal_callback(
		_done_button.pressed, func(): _fsm_controller.switch_state(State.FINISHED)
	)

	state.exit_callback = func(): _done_button.visible = false

	return state


func _define_finished_state() -> FsmState:
	var state := FsmState.new()

	state.enter_callback = func(): _submit_button.visible = true

	state.add_signal_callback(
		_submit_button.pressed, func(): _fsm_controller.switch_state(State.CLOSED)
	)

	state.exit_callback = func(): _submit_button.visible = false

	return state
