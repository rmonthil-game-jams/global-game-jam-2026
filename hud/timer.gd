extends Node3D

@export var is_fixed: bool

func _process(_delta: float) -> void:
	if not is_fixed:
		update()

func update():
	var seconds: float = Time.get_ticks_msec() / 1000.0 - get_tree().root.get_node("Game").start_time
	var minutes: int = int(seconds / 60)
	var secs: int = int(seconds) % 60
	$Label3D.text = "%02d:%02d" % [minutes, secs]
