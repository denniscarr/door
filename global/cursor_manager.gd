# Global
extends Node

signal env_highlighting_changed

var env_highlighting: bool:
	get:
		return _env_highlighting

var cursor_active: bool:
	get:
		return _cursor_active

var is_highlighting_message: bool = false
var is_highlighting_door: bool = false

var _cursor_active: bool = true
var _env_highlighting: bool = true


func _process(_delta: float):
	_refresh_cursor_shape()


func set_cursor_active(active: bool):
	_cursor_active = active
	_refresh_cursor_shape()


func enable_env_highlighting(enable: bool):
	_env_highlighting = enable
	env_highlighting_changed.emit()


func _refresh_cursor_shape():
	if not _cursor_active:
		Input.set_default_cursor_shape(Input.CURSOR_FORBIDDEN)
		return

	if is_highlighting_door:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
		return

	if is_highlighting_message:
		Input.set_default_cursor_shape(Input.CURSOR_HELP)
		return

	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
