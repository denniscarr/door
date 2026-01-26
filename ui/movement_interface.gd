class_name MovementInterface
extends Control

signal request_turn_left
signal request_turn_right
signal request_post_message

@export var _turn_left_button: Button
@export var _turn_right_button: Button
@export var _post_message_button: Button


func _ready():
	_turn_left_button.pressed.connect(_on_turn_left_button_pressed)
	_turn_right_button.pressed.connect(_on_turn_right_button_pressed)
	_post_message_button.pressed.connect(_on_post_message_button_pressed)


func set_buttons_visible(p_visible: bool):
	_turn_left_button.visible = p_visible
	_turn_right_button.visible = p_visible
	_post_message_button.visible = p_visible


func set_buttons_disabled(disabled: bool):
	_turn_left_button.disabled = disabled
	_turn_right_button.disabled = disabled
	_post_message_button.disabled = disabled


func _on_turn_left_button_pressed():
	request_turn_left.emit()


func _on_turn_right_button_pressed():
	request_turn_right.emit()


func _on_post_message_button_pressed():
	request_post_message.emit()
