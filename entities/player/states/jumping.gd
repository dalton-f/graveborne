extends State

var player

func enter():
	player = owner

func physics_update(_delta):
	var input_direction = Input.get_vector("left", "right", "forward", "backward")
	
	player.velocity.y = player.jump_velocity
	player.jumping = true
	
	if player.is_on_floor() and input_direction == Vector2.ZERO:
		state_transition.emit(self, "Idle")

	if input_direction:
		state_transition.emit(self, "Moving")
