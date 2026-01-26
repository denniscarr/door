class_name Wall
extends Node3D

@export var _door_tiles: Array[Node3D]
@export var _door: Door

var has_door: bool:
	get:
		return _has_door
var _has_door: bool


func apply_texture(tex: Texture2D):
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	for i: int in range(get_child_count()):
		var child := get_child(i)
		if child is MeshInstance3D:
			child.set_surface_override_material(0, mat)


func add_door():
	for tile: Node3D in _door_tiles:
		tile.visible = false
	_door.set_active(true)
	_has_door = true


func do_open_door():
	if not _has_door:
		return

	await _door.do_open()


## Use this to force an opening during the door transition
func force_opening():
	_door.set_active(false)
	for tile: Node3D in _door_tiles:
		tile.visible = false


func close_opening():
	if _has_door:
		add_door()
	else:
		_door.set_active(false)
		for tile: Node3D in _door_tiles:
			tile.visible = true