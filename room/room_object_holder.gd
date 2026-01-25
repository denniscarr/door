class_name RoomObjectHolder
extends Node3D


@export var _spot_light: SpotLight3D


func add_object(object: Node3D):
    add_child(object)
    _spot_light.visible = true