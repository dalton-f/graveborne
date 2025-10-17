extends CharacterBody3D

const WALK_SPEED = 6.0
const JUMP_VELOCITY = 5.0
const MOUSE_SENSITIVITY = 0.004
const ROTATION_SPEED = 12.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var grounded = true
var last_floor = true

@onready var spring_arm = $SpringArm3D
@onready var model = $Rig
@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):		
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -40, 60)
		spring_arm.rotation.y -= event.relative.x * MOUSE_SENSITIVITY

func _physics_process(delta):
	# Apply gravity
	if not grounded:
		velocity.y -= gravity * delta

	# Handle jumping
	if Input.is_action_just_pressed("jump") and grounded:
		velocity.y = JUMP_VELOCITY
		jumping = true
	
	# Detects landing
	if grounded and not last_floor:
		jumping = false
	
	# Update animation tree conditions so the correct jumping animation gets played
	animation_tree.set("parameters/conditions/grounded", grounded)
	animation_tree.set("parameters/conditions/jumping", jumping)
	
	# Detects falling
	if not grounded and not jumping:
		animation_state.travel("Jump_Idle")
		
	last_floor = grounded
	
	# Get the input direction and handle the movement/deceleration.
	var vy = velocity.y
	velocity.y = 0
	
	var input_direction = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, spring_arm.rotation.y)
	
	# Change acceleration rate based on if the player is in the air
	var acceleration_rate = 7.0 if grounded else 4.0
	
	velocity = lerp(velocity, direction * WALK_SPEED,  delta * acceleration_rate)
	velocity.y = vy

	# Update the Idle Walk Run cycle to match the velocity
	var vl = velocity * model.transform.basis
	animation_tree.set("parameters/Idle_Walk_Run_Cycle/blend_position", Vector2(vl.x, -vl.z) / WALK_SPEED)

	# Rotate the player model to follow the spring arm direction
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, ROTATION_SPEED * delta)
	
	move_and_slide()
	
	grounded = is_on_floor()
