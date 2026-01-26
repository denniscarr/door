class_name Room
extends Node3D

@export var _spot_light: SpotLight3D

@export_category("Walls 'n Shit")
@export var _wall_n: Wall
@export var _wall_s: Wall
@export var _wall_e: Wall
@export var _wall_w: Wall
@export var _floor: FloorOrCeiling
@export var _ceiling: FloorOrCeiling

@export_category("Room Objects")
@export var _asset_library: RoomAssetLibrary
@export var _room_object_holders: Array[RoomObjectHolder]

var rng_seed: int:
	get:
		return _rng_seed

var _rng_seed: int


func initialize(p_rng_seed: int):
	_rng_seed = p_rng_seed
	seed(_rng_seed)
	print("Generating room with seed: %s" % rng_seed)

	# Randomize doors
	var num_doors := randi_range(1, 4)
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
		wall.add_door()

	# Randomize room objects
	var holder := _room_object_holders.pick_random() as RoomObjectHolder
	var object := _asset_library.room_object_scenes.pick_random().instantiate() as Node3D
	holder.add_object(object)
	object.rotate_y(randf_range(-180.0, 180.0))

	# Randomize textures
	var wall_texture = _asset_library.room_wall_textures.pick_random()
	_wall_n.apply_texture(wall_texture)
	_wall_s.apply_texture(wall_texture)
	_wall_e.apply_texture(wall_texture)
	_wall_w.apply_texture(wall_texture)

	var floor_texture = _asset_library.room_wall_textures.pick_random()
	_floor.apply_texture(floor_texture)

	var ceiling_texture = _asset_library.room_wall_textures.pick_random()
	_ceiling.apply_texture(ceiling_texture)

	# Randomize lighting
	_spot_light.light_color = Color.from_hsv(randf(), 0.2, 0.8)


## Use during the walking animation to force an opening into this room from the one that
## the player's walking into it from.
func create_opening_for_entering(walk_dir: Constants.CompassDir):
	var wall_dir := _get_opposite_dir(walk_dir)
	_get_wall_by_dir(wall_dir).force_opening()


## Call after the player has entered the room and finished the animation
func close_opening_after_entering(walk_dir: Constants.CompassDir):
	var wall_dir := _get_opposite_dir(walk_dir)
	_get_wall_by_dir(wall_dir).close_opening()


func does_wall_have_door(wall_dir: Constants.CompassDir) -> bool:
	var target_wall := _get_wall_by_dir(wall_dir)
	return target_wall.has_door


func do_open_door(dir: Constants.CompassDir):
	if not does_wall_have_door(dir):
		print("No door!")
		return

	var target_wall := _get_wall_by_dir(dir)
	await target_wall.do_open_door()


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


func _get_opposite_dir(dir: Constants.CompassDir) -> Constants.CompassDir:
	match dir:
		Constants.CompassDir.NORTH:
			return Constants.CompassDir.SOUTH
		Constants.CompassDir.SOUTH:
			return Constants.CompassDir.NORTH
		Constants.CompassDir.EAST:
			return Constants.CompassDir.WEST
		_, Constants.CompassDir.WEST:
			return Constants.CompassDir.EAST
