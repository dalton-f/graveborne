extends Node

func _ready() -> void:
	print("Utilities autoload initialized.")

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

# Returns an array of all descendant nodes of the given `node`.
# Optionally, a `filter` can be applied to select specific nodes:
#   - If `filter` is null (default), all descendants are included.
#   - If `filter` is a string, only nodes whose names contain the string (case-insensitive) are included.
#   - If `filter` is a type/class, only nodes that are instances of that type are included.
# The function works recursively, searching through all levels of the node's children.
# Example usage:
#   var enemies = get_all_children(root_node, "enemy")   # get all nodes with "enemy" in their name
#   var lights = get_all_children(root_node, MeshInstance3D)      # get all MeshInstance3D nodes
func get_all_children(node: Node, filter = null) -> Array:
	var result: Array = []
	
	for child in node.get_children():
		var matches = false
		
		# If no filters, add all children to the results
		if filter == null:
			matches = true
		
		# Check for a string filter - does the child name include the string
		if typeof(filter) == TYPE_STRING:
			matches = filter.to_lower() in child.name.to_lower()
		
		# Check for node type filter
		if typeof(filter) == TYPE_OBJECT:
			matches = is_instance_of(child, filter)
		
		# Add to the array
		if matches:
			result.append(child)
			
		# Recurse into children
		result.append_array(get_all_children(child, filter))
		
	return result
