extends Node
class_name ClassManager

signal class_changed(new_class_name : String)

@export var skeleton : Skeleton3D
@export var initial_class : Class

var current_class : Class

func _ready():
	if initial_class:
		change_class(initial_class)
		
#region Class Management
func change_class(new_class : Class):
	new_class.update_meshes()
	
	for mesh in new_class.meshes:
		var duplicate_mesh = mesh.duplicate()
		skeleton.add_child(duplicate_mesh)
	
	class_changed.emit(new_class.name)
#endregion
