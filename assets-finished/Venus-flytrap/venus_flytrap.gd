extends CharacterBody3D

# --- Movement Properties ---
@export var default_speed: float = 5.0
@export var sprint_speed: float = 10.0
@export var crouch_speed: float = 2.5
@export var jump_velocity: float = 8.0
@export var acceleration: float = 10.0
@export var friction: float = 10.0

# --- Crouch/Stand Properties ---
@export var standing_height: float = 1.8 # Target height for a standing CapsuleShape3D
@export var crouching_height: float = 0.9 # Target height for a crouching CapsuleShape3D
@export var crouch_transition_speed: float = 8.0

# --- Private Variables ---
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed: float = default_speed
var is_crouching: bool = false
var capsule_collider: CollisionShape3D = null # We'll find this node in _ready

# Note: The AnimationPlayer logic is removed since the user's original animations 
# don't seem suitable for a standard player. A simple movement/idle check is kept.

func _ready():
	# Get the main CollisionShape3D to adjust its height for crouching
	# Assuming the CharacterBody3D has a child CollisionShape3D with a CapsuleShape3D
	# You might need to change the node path/type if your setup is different.
	for child in get_children():
		if child is CollisionShape3D:
			capsule_collider = child
			break
	
	if capsule_collider == null:
		print("ERROR: Could not find a CollisionShape3D child for crouching!")

# --- Main Physics Loop ---
func _physics_process(delta: float) -> void:
	
	# 1. Handle Gravity and Vertical Movement
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Reset vertical velocity on the floor (prevents accumulating gravity)
		velocity.y = 0 
		
	# 2. Handle Crouch Input (Toggle)
	var desired_crouch = Input.is_action_pressed("crouch") # Assuming 'crouch' is mapped to 'Shift'
	if desired_crouch and not is_crouching:
		is_crouching = true
	elif not desired_crouch and is_crouching:
		# Optionally add logic to check for ceiling before standing up
		is_crouching = false
	
	# 3. Handle Jump Input
	if Input.is_action_just_pressed("jump") and is_on_floor(): # Assuming 'jump' is mapped to 'Spacebar'
		velocity.y = jump_velocity
	
	# 4. Handle Movement and Sprint Input
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var is_sprinting = Input.is_action_pressed("sprint") # Assuming 'sprint' is mapped to 'Ctrl'

	if is_crouching:
		current_speed = crouch_speed
	elif is_sprinting and direction.length() > 0:
		current_speed = sprint_speed
	else:
		current_speed = default_speed

	# 5. Apply Movement (Interpolated)
	if direction:
		# Use lerp for smooth acceleration
		velocity.x = lerp(velocity.x, direction.x * current_speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * current_speed, acceleration * delta)
	else:
		# Use lerp for smooth friction/deceleration
		velocity.x = lerp(velocity.x, 0, friction * delta)
		velocity.z = lerp(velocity.z, 0, friction * delta)
		
	# 6. Adjust Crouch/Stand Collision and Position
	_handle_crouch_size(delta)

	# 7. Final Movement Calculation
	move_and_slide()

# --- Helper Functions ---

func _handle_crouch_size(delta: float):
	if capsule_collider and capsule_collider.shape is CapsuleShape3D:
		var capsule_shape: CapsuleShape3D = capsule_collider.shape
		
		var target_height = crouching_height if is_crouching else standing_height
		var target_y_offset = (standing_height - target_height) / 2.0
		
		# Smoothly change the height of the capsule
		capsule_shape.height = lerp(capsule_shape.height, target_height, crouch_transition_speed * delta)
		
		# Smoothly move the character/collision down to keep the bottom on the floor
		var new_y_offset = lerp(capsule_collider.position.y, target_y_offset, crouch_transition_speed * delta)
		capsule_collider.position.y = new_y_offset
		
		# Move the entire CharacterBody3D (optional, but ensures the feet stay planted)
		var body_offset = get_floor_height() - capsule_collider.shape.height / 2.0
		# This part is tricky in CharacterBody3D, usually moving the collision shape is enough
		# If you see floating, you may need to adjust the CharacterBody3D's global_position instead.
		# For this script, we'll rely on the CollisionShape3D adjustment.

func get_floor_height() -> float:
	# Returns the height of the character's 'feet' based on the collision shape
	if capsule_collider and capsule_collider.shape is CapsuleShape3D:
		return capsule_collider.shape.height / 2.0
	return 0.9 # Default height if no capsule is found
