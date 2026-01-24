class_name Room
extends Node

enum Direction { NORTH, SOUTH, EAST, WEST }

@export var _wall_n: Wall
@export var _wall_s: Wall
@export var _wall_e: Wall
@export var _wall_w: Wall
@export var _spot_light: SpotLight3D


func initialize(rng_seed: int):
	seed(rng_seed)
	print("Generating room with seed: %s" % rng_seed)

	var num_doors := randi_range(2, 4)
	print("Number of doors: %s" % num_doors)

	var possible_dirs := [Direction.NORTH, Direction.SOUTH, Direction.EAST, Direction.WEST]
	possible_dirs.shuffle()

	for i: int in range(num_doors):
		print("Putting door on wall: %s" % Direction.keys()[possible_dirs[i]])
		var wall := _get_wall_by_dir(possible_dirs[i])
		wall.create_door()

	_spot_light.light_color = Color.from_hsv(randf(), 0.2, 0.8)


func _get_wall_by_dir(dir: Direction) -> Wall:
	match dir:
		Direction.NORTH:
			return _wall_n
		Direction.SOUTH:
			return _wall_s
		Direction.EAST:
			return _wall_e
		_, Direction.WEST:
			return _wall_w
