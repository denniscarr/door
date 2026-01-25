class_name Wall
extends Node3D

@export var _door_tile_1: MeshInstance3D
@export var _door_tile_2: MeshInstance3D
@export var _door: Node

var has_door: bool:
	get:
		return _has_door
var _has_door: bool


func add_door():
	_door_tile_1.visible = false
	_door_tile_2.visible = false
	_door.visible = true
	_has_door = true


func do_open_door():
	if not _has_door:
		return

	# Temp, replace with better animation eventually
	await get_tree().create_timer(0.5).timeout
	_door.visible = false
	await get_tree().create_timer(0.5).timeout


## Use this to force an opening during the door transition
func force_opening():
	_door.visible = false
	_door_tile_1.visible = false
	_door_tile_2.visible = false


func close_opening():
	if _has_door:
		add_door()
	else:
		_door.visible = false
		_door_tile_1.visible = true
		_door_tile_2.visible = true
