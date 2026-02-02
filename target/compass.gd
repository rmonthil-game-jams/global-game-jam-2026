extends Node3D

var tween : Tween
var is_hiding: bool = false

func _process(_delta: float) -> void:
	var targets : Array = get_tree().get_nodes_in_group("target")
	if targets:
		# appear
		if not visible:
			show()
			scale = 1e-2 * Vector3.ONE
			if tween:
				tween.stop()
			tween = create_tween()
			tween.tween_property(self, "scale", Vector3.ONE, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		# more
		var target : Node3D = targets.front()
		look_at(target.global_position)
		#$Label3D.text = str(round(global_position.distance_to(target.global_position)) / 10.0) + "m"
		$Label3D.text = str(int(round(global_position.distance_to(target.global_position)/ 10.0))) + "m"
	else:
		if visible and not is_hiding:
			if tween:
				tween.stop()
			is_hiding = true
			tween = create_tween()
			tween.tween_property(self, "scale", 1e-2 * Vector3.ONE, 0.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
			await tween.finished
			hide()
			is_hiding = false
