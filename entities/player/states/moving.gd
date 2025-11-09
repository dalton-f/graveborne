extends State

var player

func enter():
	player = owner

func physics_update(delta: float):
	var input_direction = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, player.spring_arm.rotation.y)
	
	player.velocity.x = lerp(player.velocity.x, direction.x * player.speed, delta * player.acceleration_rate)
	player.velocity.z = lerp(player.velocity.z, direction.z * player.speed, delta * player.acceleration_rate)
	
	if input_direction.length() <= 0:
		state_transition.emit(self, "Idle")
		
	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_transition.emit(self, "Jumping")
