extends Node
class_name ClassManager

signal class_changed(new_class_name: String)

@export var initial_class : Class

var current_class : Class
var player

# Class resources will always follow the naming convention bodypart_mesh for each mesh part
# This means that we can store all expected mesh parts in an array and loop through them
# The corresponding MeshInstance on the player will also match these names
var mesh_parts = ["Head", "ArmLeft", "ArmRight", "Body", "LegLeft", "LegRight", "HeadAccessory", "ChestAccessory"]

func _ready() -> void:
	player = owner
	
	if initial_class:
		_change_class(initial_class)

#region Class Management
func _change_class(new_class):
	current_class = new_class
		
	_update_player_meshes()

	# Refresh the animation trees' animation player path
	_refresh_animation_tree()
			
	class_changed.emit(new_class.name)

func _update_player_meshes():
	current_class._update_meshes()

	var rig = player.get_node("Rig")
	var skeleton = rig.get_node("Skeleton3D")
	
	# Using the class resource, replace all the mesh parts on the player rig
	for part in mesh_parts:
		var prop_name = part.to_snake_case() + "_mesh"
		_set_mesh_if_exists(skeleton, part, current_class.get(prop_name))

func _refresh_animation_tree():
	var anim_player = player.get_node("AnimationPlayer")
	var anim_tree = player.get_node_or_null("AnimationTree")
	
	anim_tree.active = false
	anim_tree.set_animation_player(anim_player.get_path())
	anim_tree.active = true
#endregion

func _set_mesh_if_exists(root: Node, node_name: String, mesh: Mesh) -> void:	
	var node = _find_node_recursive(root, node_name)
	
	if not mesh:
		node.mesh = null
	
	if node and node is MeshInstance3D:
		node.mesh = mesh
	
	# Head accessories sometimes have a custom position, so we can update this if an accessory exists
	# Any chest accessory seems to have the same unchanged position, so the check isn't needed for those
	if node and node_name == "HeadAccessory":
		node.position = current_class.head_accessory_position
		node.rotation = current_class.head_accessory_rotation

func _find_node_recursive(node: Node, search_name: String) -> Node:
	if node.name.to_lower() == search_name.to_lower():
		return node
	
	for child in node.get_children():
		var found = _find_node_recursive(child, search_name)
		
		if found:
			return found
	
	return null
