extends Node
class_name FiniteStateManager

@export var initial_state : State

var states : Dictionary = {}
var current_state : State

signal state_changed(new_state_name: String)

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.state_transition.connect(change_state)

	if initial_state:
		initial_state.enter()
		current_state = initial_state
		state_changed.emit(current_state.name)

func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

#region State Management
func change_state(source_state : State, new_state_name : String):
	if source_state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	
	current_state = new_state
	
	state_changed.emit(current_state.name)
#endregion
