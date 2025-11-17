extends Node
class_name Interactable

signal interacted(body)

# Allows any interactable to have its own prompt message and action
@export_group("Interactable Settings")
@export var enabled = true
@export var prompt_message = "Interact"
@export var prompt_action = "interact"

func get_prompt():
	if not enabled:
		return ""
	
	var key_name := ""
	
	# Get the prompt action as text for the prompt message
	for action in InputMap.action_get_events(prompt_action):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break
		elif action is InputEventMouseButton:
			key_name = action.as_text()
	
	return "[" + key_name + "] " + prompt_message

# Emit interacted signal for individual scripts to use for interaction logic
func interact(body):
	if not enabled:
		return
	
	interacted.emit(body)
