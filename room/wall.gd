class_name Wall
extends Node

@export var _door_tile_1: MeshInstance3D
@export var _door_tile_2: MeshInstance3D


func create_door():
    _door_tile_1.visible = false
    _door_tile_2.visible = false