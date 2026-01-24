extends Node3D

@export var _starting_room: Room
@export_range(0, 99) var _starting_pos_x: int = 49
@export_range(0, 99) var _starting_pos_y: int = 49

@onready var _seed_x := _starting_pos_x
@onready var _seed_y := _starting_pos_y


func _ready():
	_starting_room.initialize(_get_seed())


func _get_seed() -> int:
	var combined := str(_seed_x) + str(_seed_y)
	return int(combined)
