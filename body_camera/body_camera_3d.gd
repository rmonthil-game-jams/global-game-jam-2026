extends RigidBody3D

const TARGET_DISTANCE_TO_GROUND := 20.0
const MOVE_SPEED := 24.0
const JETPACK_SPEED := 1.5 * MOVE_SPEED
const JUMP_SPEED := 96.0
const MOUSE_SENSITIVITY := 0.003
const LINEAR_REACTION_TIME := 0.04
const ANGULAR_REACTION_TIME := 0.04
const FALL_DAMAGE_SPEED := 128.0
const HAS_JETPACK := true

@onready var camera_y: float = $Camera3D.global_rotation.y
@onready var camera_x: float = $Camera3D.global_rotation.x

# internal
var is_on_ground : bool = false
var can_jump : bool = false
var is_jumping : bool = false

func _input(event):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			camera_y -= event.relative.x * MOUSE_SENSITIVITY
			camera_x -= event.relative.y * MOUSE_SENSITIVITY
			camera_x = clamp(camera_x, -1.55, 1.55)
	elif event is InputEventMouseButton:
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	# raycast
	$RayCast3D.global_rotation = Vector3.ZERO
	# camera
	$Camera3D.global_rotation.x = camera_x
	$Camera3D.global_rotation.y = camera_y
	$Camera3D.global_rotation.z = 0.0
	
	# is on ground
	var distance_to_ground : float = ( $RayCast3D.global_position.y - $RayCast3D.get_collision_point().y)
	var previous_is_on_ground : bool = is_on_ground
	is_on_ground = $RayCast3D.is_colliding() and distance_to_ground > 0.0 * TARGET_DISTANCE_TO_GROUND and distance_to_ground < TARGET_DISTANCE_TO_GROUND + 1.0
	if is_on_ground:
		can_jump = true
		# sound
		if previous_is_on_ground != is_on_ground and not $JumpLandingSound.playing:
			$JumpLandingSound.play()
		# damages
		if linear_velocity.y < 0.0:
			var fall_damage: int = pow(-linear_velocity.y / FALL_DAMAGE_SPEED, 3)
			if fall_damage > 0:
				$Camera3D/Life.life -= fall_damage
	else:
		if not $FootStepTimer.is_stopped():
			$FootStepTimer.stop()
		if can_jump and $CoyoteTimer.is_stopped():
			$CoyoteTimer.start()
	
	# move
	var dir := Vector3.ZERO
	if Input.is_action_pressed("move_frontwards"):
		dir -= $Camera3D.global_transform.basis.z
	if Input.is_action_pressed("move_backwards"):
		dir += $Camera3D.global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		dir -= $Camera3D.global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		dir += $Camera3D.global_transform.basis.x
	
	if dir != Vector3.ZERO:
		dir = Plane(Vector3.UP).project(dir)
		dir = dir.normalized()
		if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	linear_velocity += (dir * MOVE_SPEED - Plane(Vector3.UP).project(linear_velocity)) * delta / LINEAR_REACTION_TIME
	if is_on_ground and not is_jumping:
		linear_velocity += ( (TARGET_DISTANCE_TO_GROUND - distance_to_ground) / LINEAR_REACTION_TIME - linear_velocity.y)  * Vector3.UP * delta / LINEAR_REACTION_TIME

	if dir:
		if is_on_ground and $FootStepTimer.is_stopped():
			$FootStepTimer.start()
	else:
		if not $FootStepTimer.is_stopped():
			$FootStepTimer.stop()

	# jump
	if is_jumping:
		if is_on_ground:
			is_jumping = false
	elif can_jump:
		if Input.is_action_just_pressed("move_jump"):
			linear_velocity.y += JUMP_SPEED
			is_jumping = true
			can_jump = false
			$JetPackTimer.start()
			$JumpSound.play()
			if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if HAS_JETPACK and $Camera3D/JetPack.fuel > 0.0 and Input.is_action_pressed("move_jump") and $JetPackTimer.is_stopped():
		linear_velocity.y += max(JETPACK_SPEED - linear_velocity.y, 0.0) * delta / LINEAR_REACTION_TIME
		$Camera3D/JetPack.fuel -= 1e-1 * max(JETPACK_SPEED - linear_velocity.y, 0.0) * delta
		if not $Camera3D/JetPackSound.playing:
			$Camera3D/JetPackSound.play()
		if $Camera3D/JetPack/Bars/Marker3D/Bar.mesh.material.albedo_color.h != 45.0/360.0:
			$Camera3D/JetPack/Bars/Marker3D/Bar.mesh.material.albedo_color.h = 45.0/360.0
			$Camera3D/JetPack/BarsEmpty/Bar.mesh.material.albedo_color.h = 45.0/360.0
	else:
		if $Camera3D/JetPackSound.playing:
			$Camera3D/JetPackSound.stop()
		if $Camera3D/JetPack/Bars/Marker3D/Bar.mesh.material.albedo_color.h != 160.0/360.0:
			$Camera3D/JetPack/Bars/Marker3D/Bar.mesh.material.albedo_color.h = 160.0/360.00
			$Camera3D/JetPack/BarsEmpty/Bar.mesh.material.albedo_color.h = 160.0/360.0

	# stabilize
	var angle_dir: Vector3 = Vector3.UP.cross(global_transform.basis.y)
	if angle_dir != Vector3.ZERO:
		angular_velocity += -abs(global_transform.basis.y.angle_to(Vector3.UP)) * angle_dir.normalized() * delta / pow(ANGULAR_REACTION_TIME, 2)
	angular_velocity += (Vector3.ZERO - angular_velocity) * delta / ANGULAR_REACTION_TIME

func _on_coyote_timer_timeout() -> void:
	can_jump = false

func _on_jet_pack_timer_timeout() -> void:
	pass # Replace with function body.

func _on_foot_step_timer_timeout() -> void:
	$FootstepsSound.play()
