# This script is designed for use with KayKit-style character models.
# It assumes that each mesh node in the model_scene is seperate and has the following naming convention:
#     e.g. "Head", "ArmLeft", "ArmRight", "Body", "LegLeft", "LegRight", "Chest", etc.
# This script also assumes that Skeleton3D is the root node
# Accessory meshes on KayKit character models generally hold additional meshes for helmets, hats, and capes

extends Resource
class_name Class

@export var name: String
@export var model_scene: PackedScene

var head_mesh: MeshInstance3D
var arm_left_mesh: MeshInstance3D
var arm_right_mesh: MeshInstance3D
var body_mesh: MeshInstance3D
var leg_left_mesh: MeshInstance3D
var leg_right_mesh: MeshInstance3D

var accessories := {}

func _update_meshes():
	var scene_instance = model_scene.instantiate()

	# Automatically save the MeshInstance node for each part of the class' model
	head_mesh = _find_mesh(scene_instance, "head")
	arm_left_mesh = _find_mesh(scene_instance, "armleft")
	arm_right_mesh = _find_mesh(scene_instance, "armright")
	body_mesh = _find_mesh(scene_instance, "body")
	leg_left_mesh = _find_mesh(scene_instance, "legleft")
	leg_right_mesh = _find_mesh(scene_instance, "legright")
	
	# Dynamically find accessories (any additional mesh instances on the character)
	_find_accessories(scene_instance)

func _find_accessories(root: Node):
	# All accessory terms found within KayKit's Adventures pack
	var accessory_terms = ["helmet", "hat", "cape", "backpack", "mask", "quiver", "goggles"]

	# TODO: refactor this to flatten the logic
	for node in root.get_children():
		if node is MeshInstance3D:
			for accessory_term in accessory_terms:
				if accessory_term in node.name.to_lower():
					var parts = node.name.split("_")
					# Find the PascalCase accesory name while removing the Character_ prefix
					var accessory_name = parts[1].replace(" ", "") if parts.size() > 1 else node.name.replace(" ", "")
					
					accessories[accessory_name] = {
						"mesh": node,
						"position": node.position,
						"rotation": node.rotation
					}

# Attempts to find a MeshInstance3D child node out of all the children of the root node
func _find_mesh(root: Node, search_term: String) -> MeshInstance3D:
	for node in root.get_children():
		var found = _find_mesh_in_node(node, search_term)
		
		if found:
			return found
	
	return null

func _find_mesh_in_node(node: Node, search_term: String) -> MeshInstance3D:
	# Save the node
	if node is MeshInstance3D and search_term in node.name.to_lower():
		return node
	
	# Recursively check layers of children
	for child in node.get_children():
		var found = _find_mesh_in_node(child, search_term)
		
		if found:
			return found

	return null
