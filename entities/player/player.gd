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
@onready var finite_state_manager: FiniteStateManager = $Managers/FiniteStateManager
@onready var class_manager: ClassManager = $Managers/ClassManager
@onready var state_label: Label = $CanvasLayer/MarginContainer/StateLabel
@onready var class_label: Label = $CanvasLayer/MarginContainer/ClassLabel

func _ready() -> void:
	# Hide the cursor and lock it to the center of the screen but ensure it can still be captured
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	finite_state_manager.connect("state_changed", _on_state_changed)
	class_manager.connect("class_changed", _on_class_changed)
	state_label.text = finite_state_manager.initial_state.name
	class_label.text = class_manager.initial_class.name
	
	move_and_slide()
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity

#region Player Movement
func _physics_process(delta):
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle landing on the floor after being in the air
	if is_on_floor() and not last_floor:
		jumping = false
	
	# Handle falling without having jumped
	if not is_on_floor() and not jumping:
		animation_state.travel("Jump_Idle")

	last_floor = is_on_floor()
	
	# Update the animation tree for the correct jumping animation
	animation_tree.set("parameters/conditions/grounded", is_on_floor())
	animation_tree.set("parameters/conditions/jumping", jumping)
	
	# Convert velocity into the model space
	var vl = velocity * model.transform.basis
	# Divide by speed so that the 3D vl vector can be mapped to a 2D blendspace with a value between -1 and 1
	animation_tree.set("parameters/Idle_Walk_Run_Cycle/blend_position", Vector2(vl.x, -vl.z) / speed)

	# Change FOV based on speed
	var velocity_clamped = clamp(velocity.length(), 0.5, speed * 2)
	var target_fov = base_fov + fov_change * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	move_and_slide()
#endregion

func _on_state_changed(new_state_name):
	state_label.text = new_state_name

func _on_class_changed(new_class_name):
	class_label.text = new_class_name
