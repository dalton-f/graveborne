@tool
extends Node
class_name ClassManager

@warning_ignore("unused_signal")
signal class_changed(new_class_name: String)

@export var initial_class : Class

var current_class : Class
var player

func _ready() -> void:
	player = owner
	
	if initial_class:
		_change_class(initial_class)

#region Class Management
func _change_class(new_class):
	current_class = new_class
	
	# Clear any old rig on the player
	var old_rig = player.get_node_or_null("Rig/Skeleton3D")
	
	if old_rig:
		old_rig.queue_free()
	
	# Instantiate the new rig
	var model = new_class.model_scene.instantiate()
	player.get_node("Rig").add_child(model)
	
	class_changed.emit(initial_class.name)
#endregion
