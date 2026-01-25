class_name Room
extends Node3D

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

	var possible_dirs := [
		Constants.CompassDir.NORTH,
		Constants.CompassDir.SOUTH,
		Constants.CompassDir.EAST,
		Constants.CompassDir.WEST
	]
	possible_dirs.shuffle()

	for i: int in range(num_doors):
		print("Putting door on wall: %s" % Constants.CompassDir.keys()[possible_dirs[i]])
		var wall := _get_wall_by_dir(possible_dirs[i])
		wall.create_door()

	_spot_light.light_color = Color.from_hsv(randf(), 0.2, 0.8)


func _get_wall_by_dir(dir: Constants.CompassDir) -> Wall:
	match dir:
		Constants.CompassDir.NORTH:
			return _wall_n
		Constants.CompassDir.SOUTH:
			return _wall_s
		Constants.CompassDir.EAST:
			return _wall_e
		_, Constants.CompassDir.WEST:
			return _wall_w
