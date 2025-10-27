# This script is designed for use with KayKit-style character models.
# It assumes that each mesh node in the model_scene is seperate and has the following naming convention:
#     e.g. "Head", "ArmLeft", "ArmRight", "Body", "LegLeft", "LegRight", "Chest", etc.

# Accessory meshes on KayKit character models generally hold additional meshes for helmets, hats, and capes
# Accessory meshes are expected as the first child of "head" or "chest" bone nodes.
# If these bone nodes do not exist, they will be ignored

extends Resource
class_name Class

@export var name: String
@export var model_scene: PackedScene

var head_mesh: Mesh
var arm_left_mesh: Mesh
var arm_right_mesh: Mesh
var body_mesh: Mesh
var leg_left_mesh: Mesh
var leg_right_mesh: Mesh
var chest_accessory_mesh: Mesh
var head_accessory_mesh: Mesh

var head_accessory_position: Vector3
var head_accessory_rotation: Vector3

func _update_meshes():
	var scene_instance = model_scene.instantiate()

	# Automatically save references to each part of the class' mesh
	head_mesh = _find_mesh(scene_instance, "head")
	arm_left_mesh = _find_mesh(scene_instance, "armleft")
	arm_right_mesh = _find_mesh(scene_instance, "armright")
	body_mesh = _find_mesh(scene_instance, "body")
	leg_left_mesh = _find_mesh(scene_instance, "legleft")
	leg_right_mesh = _find_mesh(scene_instance, "legright")
	
	# Find accessories if they exist
	if scene_instance.get_node_or_null("head"):
		# Accessory mesh will always be the first child
		head_accessory_mesh = scene_instance.get_node("head").get_child(0).mesh
		head_accessory_position = scene_instance.get_node("head").get_child(0).position
		head_accessory_rotation = scene_instance.get_node("head").get_child(0).rotation
	
	if scene_instance.get_node_or_null("chest"):
		# Assume that all chest accessories have the same position and rotation
		chest_accessory_mesh = scene_instance.get_node("chest").get_child(0).mesh


# Attempts to find a MeshInstance3D child node out of all the children of the root node
func _find_mesh(root: Node, search_term: String) -> Mesh:
	for node in root.get_children():
		var found = _find_mesh_in_node(node, search_term)
		
		if found:
			return found
	
	return null

func _find_mesh_in_node(node: Node, search_term: String) -> Mesh:
	if node is MeshInstance3D and search_term in node.name.to_lower():
		return node.mesh
	
	# Recursively check layers of children
	for child in node.get_children():
		var found = _find_mesh_in_node(child, search_term)
		
		if found:
			return found

	return null
