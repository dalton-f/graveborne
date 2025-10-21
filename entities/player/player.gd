extends CharacterBody3D
class_name Player

@export_group("Movement Settings")
@export var speed = 5.0
@export var jump_velocity = 6
@export var acceleration = 4.0

@export_group("Camera Settings")
@export var mouse_sensitivity = 0.003
@export var rotation_speed = 12.0

@export_group("FOV Settings")
@export var base_fov = 75.0
@export var fov_change = 1.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var last_floor = true

@onready var spring_arm = $CameraMount
@onready var camera = $CameraMount/Camera
@onready var model = $Rig
@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")

func _ready() -> void:
	# Hide the cursor and lock it to the center of the screen but ensure it can still be captured
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

func _physics_process(delta):
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity
		jumping = true

	# Handle landing on the floor after being in the air
	if is_on_floor() and not last_floor:
		jumping = false	
	
	# Handle falling without having jumped
	if not is_on_floor() and not jumping:
		animation_state.travel("Jump_Idle")

	last_floor = is_on_floor()
	
	animation_tree.set("parameters/conditions/grounded", is_on_floor())
	animation_tree.set("parameters/conditions/jumping", jumping)
	
	# Handle movement
	var input_direction = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(input_direction.x, 0, input_direction.y).rotated(Vector3.UP, spring_arm.rotation.y)
	velocity.x = lerp(velocity.x, direction.x * speed, delta * acceleration)
	velocity.z = lerp(velocity.z, direction.z * speed, delta * acceleration)
	
	# Convert velocity into the model space
	var vl = velocity * model.transform.basis
	# Divide by speed so that the 3D vl vector can be mapped to a 2D blendspace with a value between -1 and 1
	animation_tree.set("parameters/Idle_Walk_Run_Cycle/blend_position", Vector2(vl.x, -vl.z) / speed)

	# Change FOV based on speed
	var velocity_clamped = clamp(velocity.length(), 0.5, speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	# Rotate the character so they face in the direction of movement
	# Using lerp_angle() ensures we’ll always rotate the shortest direction to the new angle
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)

	move_and_slide()
