extends State

var player

func enter():
	player = owner

func physics_update(delta):
	var input_direction = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, player.spring_arm.rotation.y)
	player.velocity.x = lerp(player.velocity.x, direction.x * player.speed, delta * player.acceleration)
	player.velocity.z = lerp(player.velocity.z, direction.z * player.speed, delta * player.acceleration)
	
	# Rotate the character so they face in the direction of movement
	# Using lerp_angle() ensures we’ll always rotate the shortest direction to the new angle
	if player.velocity.length() > 1.0:
		player.model.rotation.y = lerp_angle(player.model.rotation.y, player.spring_arm.rotation.y, player.rotation_speed * delta)
	
	# Change back to the idle state after movement has stopped	
	if not input_direction:
		state_transition.emit(self, "Idle")
	
	# Change to the jumping state
	if player.is_on_floor() and Input.is_action_just_pressed("jump"):
		state_transition.emit(self, "Jumping")
