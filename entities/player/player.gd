extends CharacterBody3D
class_name Player

@export_group("Movement Settings")
@export var speed = 5.0
@export var acceleration_rate = 3.0
@export var jump_force = 5.8

@export_group("Mouse Settings")
@export var mouse_sensitivity = 0.002
@export var rotation_speed = 12.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping = false
var was_on_floor = true

@onready var spring_arm = $SpringArm3D
@onready var model = $Rig_Medium
@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")
@onready var finite_state_manager: FiniteStateManager = $Managers/FiniteStateManager
@onready var state_label: Label = $UI/MarginContainer/StateLabel

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	finite_state_manager.connect("state_changed", handle_state_change)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

func _physics_process(delta):
	move_and_slide()
		
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle landing after a jump
	if is_on_floor() and not was_on_floor:
		jumping = false
	
	# Handle falling without having jumped
	if not is_on_floor() and not jumping:
		animation_state.travel("Jump_Idle") 
	
	was_on_floor = is_on_floor()
	
	# Update animation tree parameters to ensure correct animation for jumping gets played
	animation_tree.set("parameters/conditions/grounded", is_on_floor())
	animation_tree.set("parameters/conditions/jumping", jumping)
	
	# Convert velocity to a Vector2 with values between 1 and -1 for the blendspace
	var vl = velocity * model.transform.basis
	animation_tree.set("parameters/Idle_Walk_Run_Cycle/blend_position", Vector2(vl.x, -vl.z) / speed)

	# Rotate the model to face and move towards the camera direction
	if velocity.length() > 1.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)

# Temporary code for debugging
func handle_state_change(new_state_name):
	state_label.text = new_state_name
