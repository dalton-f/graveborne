extends Resource
class_name Class

@export_group("Class Customisation")
@export var name : String
@export var scene : PackedScene

var meshes := []
var scene_instance

func update_meshes():
	if scene:
		scene_instance = scene.instantiate()
	else:
		push_warning("No scene assigned to this class resource.")

	var mesh_children = Utilities.get_all_children(scene_instance, MeshInstance3D)
	
	meshes = mesh_children
