extends Node

var start_time: float

func restart():
	$AudioStreamPlayerLose1.play()
	$AudioStreamPlayerLose2.play()
	# clean
	get_children().back().queue_free()
	# instanciate
	start_time = Time.get_ticks_msec() / 1000.0
	var new_level: Node = preload("res://level.tscn").instantiate()
	add_child(new_level)
	new_level.get_node("Intro/Camera3D").current = false
	new_level.get_node("Intro/Camera3D").hide()

func _ready() -> void:
	start_time = Time.get_ticks_msec() / 1000.0
	add_child(preload("res://level.tscn").instantiate())

# input manager

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.physical_keycode:
			KEY_ESCAPE:
				var current_mode = DisplayServer.window_get_mode()
				if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			#KEY_P:
				#var image = get_viewport().get_texture().get_image()
				#var date = Time.get_datetime_string_from_system()
				#var file_name = "screenshot-" + date + ".jpg"
				#var path = "res://screenshots/" + file_name
				#var dir = DirAccess.open("res://")
				#if not dir.dir_exists("screenshots"):
					#dir.make_dir("screenshots")
				#image.save_jpg(path)
