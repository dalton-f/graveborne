extends State

var player

func enter():
	player = owner
	
func physics_update(delta: float):
	var input_direction = Input.get_vector("left", "right", "forward", "backward")
	
	# Ensure the player continues to move towards 0 velocity even if there is no input direction
	player.velocity.x = lerp(player.velocity.x, 0.0, delta * player.acceleration_rate * 1.5)
	player.velocity.z = lerp(player.velocity.z, 0.0, delta * player.acceleration_rate * 1.5)
	
	if input_direction:
		state_transition.emit(self, "Moving")
		
	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_transition.emit(self, "Jumping")
