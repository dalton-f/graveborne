extends State

var player

func enter():
	player = owner

func physics_update(_delta: float):
	var input_direction = Input.get_vector("left", "right", "forward", "backward")
	
	# Handle jumping
	player.velocity.y = player.jump_force
	player.jumping = true

	if input_direction.length() <= 0:
		state_transition.emit(self, "Idle")
	
	if input_direction:
		state_transition.emit(self, "Moving")
