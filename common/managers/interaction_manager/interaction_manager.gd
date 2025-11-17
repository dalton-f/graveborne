extends Area3D
class_name InteractionManager

var nearby_interactables: Array = []

@onready var interaction_prompt: Label = $MarginContainer/InteractionPrompt

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta):
	interaction_prompt.text = ""
	
	if nearby_interactables.size() == 0:
		return
	
	# Find the closest interactable if we overlap multiple
	var closest = _get_closest_interactable()

	if closest:
		# Update prompt
		interaction_prompt.text = closest.get_prompt()
	
		# Handle the actual interaction
		if Input.is_action_just_pressed(closest.prompt_action):
			closest.interact(owner)

# Constantly keep track of any Interactables that we are close to
func _on_body_entered(body):
	if body is Interactable and body not in nearby_interactables:
		nearby_interactables.append(body)

func _on_body_exited(body):
	if body in nearby_interactables:
		nearby_interactables.erase(body)

# Nearest neighbour brute-force search implementation
func _get_closest_interactable() -> Interactable:
	var closest: Interactable = null
	var closest_dist = INF
	
	for interactable in nearby_interactables:
		var dist = global_position.distance_to(interactable.global_position)
		
		if dist < closest_dist:
			closest = interactable
			closest_dist = dist
	
	return closest
