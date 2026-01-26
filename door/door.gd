class_name Door
extends Node3D

@export var _hinge: Node3D
@export var _shape: CollisionShape3D


func set_active(active: bool):
    visible = active
    _shape.disabled = !active


func do_open():
    var open_tween := create_tween()
    var target_rotation := Vector3(0.0, 120.0, 0.0)
    open_tween.tween_property(_hinge, "rotation_degrees", target_rotation, 1.0)
    await open_tween.finished