class_name Player
extends Node3D

func _input(event: InputEvent):
    if not event is InputEventKey:
        return
    