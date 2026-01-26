# Global
extends Node

signal env_highlighting_changed

enum HighlightType {
	NONE,
	DOOR,
	MESSAGE,
}

var env_highlighting: bool:
	get:
		return _env_highlighting

var cursor_active: bool:
	get:
		return _cursor_active

var _cursor_active: bool = true
var _env_highlighting: bool = true


func set_cursor_active(active: bool):
	_cursor_active = active
	if active:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func enable_env_highlighting(enable: bool):
	_env_highlighting = enable
	env_highlighting_changed.emit()