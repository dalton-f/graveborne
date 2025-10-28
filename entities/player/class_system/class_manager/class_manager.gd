extends Node
class_name ClassManager

signal class_changed(new_class_name: String)

@export var initial_class : Class
@export var all_classes: Array[Class] = []

var current_class : Class
var player
var current_index: int = 0

# Class resources will always follow the naming convention bodypart_mesh for each mesh part
# This means that we can store all expected mesh parts in an array and loop through them
# The corresponding MeshInstance on the player will also match these names
var mesh_parts = ["Head", "ArmLeft", "ArmRight", "Body", "LegLeft", "LegRight"]

func _ready() -> void:
	player = owner
	
	if initial_class:
		_change_class(initial_class)

# Temporary code to test swapping classes with animations
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("change_class"):
		_cycle_class()

func _cycle_class() -> void:
	if all_classes.size() == 0:
		return
	
	current_index = (current_index + 1) % all_classes.size()
	_change_class(all_classes[current_index])


#region Class Management
func _change_class(new_class):
	current_class = new_class
		
	_update_player_meshes()

	# Refresh the animation trees' animation player path
	_refresh_animation_tree()
			
	class_changed.emit(new_class.name)

func _update_player_meshes():
	current_class._update_meshes()

	var rig = player.get_node("Rig_Medium")
	var skeleton = rig.get_node("Skeleton3D")
	
	# Clear any previous class meshes
	for child in skeleton.get_children():
		if child is MeshInstance3D:
			child.queue_free()
	
	# Using the class resource, add all new mesh instances as children on the player rig
	for part in mesh_parts:
		var prop_name = part.to_snake_case() + "_mesh"
		_create_mesh_node(skeleton, part, current_class.get(prop_name))
	
	_update_accessories(skeleton)

func _update_accessories(skeleton: Node):
	if not current_class.accessories:
		return

	# Loop through the class accesory data
	for accessory_name in current_class.accessories.keys():
		var accessory_data = current_class.accessories[accessory_name]
		var mesh = accessory_data.get("mesh")
		
		if not mesh:
			continue
	
		# TODO: find a way to use _create_mesh_node for this to
		# Dynamically add new meshes under the player skeleton for any accessory
		var node = mesh.duplicate()
		node.name = accessory_name.capitalize()
		skeleton.add_child(node)

		# Ensure that the position and rotation is correct
		node.position = accessory_data.position
		node.rotation = accessory_data.rotation
#endregion

func _refresh_animation_tree():
	var anim_player = player.get_node("AnimationPlayer")
	var anim_tree = player.get_node_or_null("AnimationTree")
	
	anim_tree.active = false
	anim_tree.set_animation_player(anim_player.get_path())
	anim_tree.active = true

func _create_mesh_node(root: Node, node_name: String, mesh: MeshInstance3D) -> void:
	if not mesh:
		return
	
	var node = mesh.duplicate()
	node.name = node_name

	root.add_child(node)
