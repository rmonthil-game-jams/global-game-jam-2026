extends Node3D

const TARGET_SPEED: float = 32.0
const GRAVITY_SPEED: float = 16.0

# TODO: USE RIGIDBODY ...

@onready var voxel_lod_terrain : VoxelLodTerrain = get_parent().get_node("VoxelLodTerrain")
@onready var voxel_tool : VoxelTool = voxel_lod_terrain.get_voxel_tool()
@onready var target_manager : Node = get_parent().get_node("TargetManager")

func _physics_process(delta: float) -> void:
	# newton method
	var value: float = sdf_value()
	if value < 0.125 or $Area3DExterior.get_overlapping_bodies():
		var grad: Vector3 = sdf_gradient(1.0)
		var grad_norm: float = grad.length()
		if grad_norm > 0.0:
			global_position += delta * TARGET_SPEED * grad/grad_norm
		else:
			global_position += delta * Vector3.UP.rotated(
				Vector3.RIGHT, randf_range(0.0, TAU)
			).rotated(Vector3.BACK, randf_range(0.0, TAU))
		if $Timer.is_stopped():
			$Timer.start()
	elif not $Timer.is_stopped():
		$Timer.stop()
	global_position.y -= GRAVITY_SPEED * delta

func sdf_value():
	return voxel_tool.get_voxel_f(global_position)

func sdf_gradient(dx: float):
	var grad : Vector3 = Vector3.ZERO
	grad.x = voxel_tool.get_voxel_f(global_position + dx * Vector3.RIGHT) - voxel_tool.get_voxel_f(global_position + dx * Vector3.LEFT)
	grad.y = voxel_tool.get_voxel_f(global_position + dx * Vector3.UP) - voxel_tool.get_voxel_f(global_position + dx * Vector3.DOWN)
	grad.z = voxel_tool.get_voxel_f(global_position + dx * Vector3.BACK) - voxel_tool.get_voxel_f(global_position + dx * Vector3.FORWARD)
	return grad

func _on_timer_timeout() -> void:
	target_manager.spawn_target()
	queue_free()
