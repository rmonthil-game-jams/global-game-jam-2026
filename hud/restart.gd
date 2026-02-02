extends Node3D

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_R and event.pressed:
			if visible:
				get_tree().root.get_node("Game").restart()
