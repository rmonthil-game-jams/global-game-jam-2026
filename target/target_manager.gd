extends Node

const INIT_DISTANCE: float = 128.0

var distance: float = INIT_DISTANCE

@onready var body_camera_3d: RigidBody3D = get_parent().get_node("BodyCamera3D")
@onready var compass: Node3D = body_camera_3d.find_child("Compass")

func spawn_target():
	var new_target: Node3D = preload("res://target/target.tscn").instantiate()
	new_target.position = body_camera_3d.global_position + distance * Vector3.UP.rotated(
		Vector3.RIGHT, randf_range(-PI, PI)
	).rotated(Vector3.BACK, randf_range(-PI, PI))
	get_parent().add_child.call_deferred(new_target)

func _ready() -> void:
	# connect
	compass.get_node("Area3D").area_entered.connect(_on_compass_target_entered)

func _on_compass_target_entered(target: Area3D):
	target.get_node("CollisionShape3D").disabled = true
	target.get_parent().process_mode = Node.PROCESS_MODE_DISABLED
	target.get_parent().get_node("Timer").stop()
	target.get_parent().get_node("Timer").queue_free()
	target.get_parent().remove_from_group("target")
	# success animation
	body_camera_3d.freeze = true
	var tween: Tween = create_tween()
	var d: float = target.get_parent().global_position.distance_to(body_camera_3d.get_node("Camera3D").global_position)
	tween.tween_property(target.get_parent(), "global_position", body_camera_3d.get_node("Camera3D").global_position, d/48.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(
		func():
			body_camera_3d.get_node("Camera3D/Orbs").number += 1
			#body_camera_3d.get_node("Camera3D/Life").life += 1
			body_camera_3d.get_node("Camera3D/JetPack").fuel += 0.5
	)
	tween.tween_property(target.get_parent().get_node("MeshInstance3D"), "mesh:material:albedo_color:a", 0.0, 0.15).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	await tween.finished
	await get_tree().process_frame
	# increase score
	body_camera_3d.freeze = false
	target.get_parent().get_node("MeshInstance3D").mesh.material.albedo_color.a = 0.75
	target.get_parent().queue_free()
	await get_tree().create_timer(1.0).timeout
	spawn_target()
	distance += 32
