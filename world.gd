extends Node3D

func _on_area_3d_body_shape_entered(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	$Player.position = Vector3(0,-40,0)


func _on_area_3d2_body_shape_entered(_body_rid: RID, _body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	$Player.position = Vector3(0,0,-30)
