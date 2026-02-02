extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	# hide
	$Environment.hide()
	$VoxelLodTerrain.hide()
	$BodyCamera3D.hide()
	# wait loading
	$BodyCamera3D.freeze = true
	await  get_tree().create_timer(4.0).timeout
	# set character
	$BodyCamera3D.global_position.y = $BodyCamera3D/RayCast3D.get_collision_point().y + $BodyCamera3D.TARGET_DISTANCE_TO_GROUND
	$BodyCamera3D.freeze = false
	# show
	$Environment.show()
	$VoxelLodTerrain.show()
	$BodyCamera3D.show()
	$BodyCamera3D.global_rotation = Vector3.ZERO
	$BodyCamera3D/Camera3D.rotation = Vector3.ZERO
	# spawn first target
	await  get_tree().create_timer(1.0).timeout
	$TargetManager.spawn_target()
