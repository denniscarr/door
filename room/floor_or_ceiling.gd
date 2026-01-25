class_name FloorOrCeiling
extends Node3D


func apply_texture(tex: Texture2D):
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = tex
	for i: int in range(get_child_count()):
		var child := get_child(i)
		if child is MeshInstance3D:
			child.set_surface_override_material(0, mat)
