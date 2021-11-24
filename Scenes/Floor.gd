extends StaticBody

func resize(x,z):
	$FloorCollisionShape.shape.extents.x = x*0.5
	$FloorCollisionShape.shape.extents.z = z*0.5
	$FloorCollisionShape.translation.x = x*0.5
	$FloorCollisionShape.translation.z = z*0.5
	$MeshInstance.mesh.size.x = x
	$MeshInstance.mesh.size.z = z
	$MeshInstance.translation.x = x*0.5
	$MeshInstance.translation.z = z*0.5
