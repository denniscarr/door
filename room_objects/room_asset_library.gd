class_name RoomAssetLibrary
extends Resource

@export var _room_object_scenes: Array[PackedScene]

var room_object_scenes: Array[PackedScene]:
	get:
		return _room_object_scenes
