extends CharacterBody3D

var interactable_looked_at: Object

var is_crouching: bool
var stand_height: float

const CROUCH_HEIGHT = 1.4
const SPEED = 5.0
const CROUCH_SPEED = 2.5
const LOOK_SENSITIVITY = 0.5

func _init() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _ready() -> void:
	stand_height = ($CollisionShape3D.shape as CapsuleShape3D).height
	$Camera3D.rotation = Vector3(0,0,0)

func _process(delta: float) -> void:
	_calculate_look(delta)

func _physics_process(delta: float) -> void:
	_calculate_movement(delta)
	
	_notify_player_look()
	
	if Input.is_action_just_pressed("g_intr"):
		_notify_interact()

	if Input.is_action_pressed("g_crouch"):
		_crouch()
	elif Input.is_action_just_released("g_crouch"):
		_stand()
	
	if Input.is_action_just_pressed("g_crouch_toggle"):
		_crouch_toggle()
		
func _calculate_look(delta: float) -> void:
	var look := (Input.get_last_mouse_velocity() * delta / 100)  * LOOK_SENSITIVITY
	#rotate viewpoint/player body
	if $Camera3D.rotation_degrees.x + -look.y >= 90:
		$Camera3D.rotation_degrees.x = 90	
	elif $Camera3D.rotation_degrees.x + -look.y <= -90:
		$Camera3D.rotation_degrees.x = -90	
	else:
		$Camera3D.rotate_x(-look.y)
	rotate_y(-look.x)
func _calculate_movement(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("g_l", "g_r", "g_fwd", "g_bck")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if is_crouching:
			velocity.x = direction.x * CROUCH_SPEED
			velocity.z = direction.z * CROUCH_SPEED
		else:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _notify_player_look() -> void:
	if $Camera3D/RayCast3D.is_colliding():
		var obj = $Camera3D/RayCast3D.get_collider()
		obj.player_lookat()
		interactable_looked_at = obj
	elif interactable_looked_at != null:
		interactable_looked_at.player_stop_look()
		interactable_looked_at = null

func _notify_interact() -> void:
	if $Camera3D/RayCast3D.is_colliding():
		var obj = $Camera3D/RayCast3D.get_collider()
		obj.use_object()

#todo: crouch
func _crouch() -> void:
	$Camera3D.position = $Camera_crouchpos.position
	($CollisionShape3D.shape as CapsuleShape3D).height = CROUCH_HEIGHT
	is_crouching = true

func _stand() -> void:
	$Camera3D.position = $Camera_standpos.position
	($CollisionShape3D.shape as CapsuleShape3D).height = stand_height
	is_crouching = false

func _crouch_toggle() -> void:
	if is_crouching:
		_stand()
	else:
		_crouch()
