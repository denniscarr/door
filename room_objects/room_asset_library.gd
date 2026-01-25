class_name RoomAssetLibrary
extends Resource

@export var _room_object_scenes: Array[PackedScene]
@export var _room_wall_textures: Array[Texture2D]

var room_object_scenes: Array[PackedScene]:
	get:
		return _room_object_scenes

var room_wall_textures: Array[Texture2D]:
	get:
		return _room_wall_textures
