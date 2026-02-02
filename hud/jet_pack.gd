extends Node3D

var fuel: float = 5.0:
	set(value):
		fuel = max(value, 0)
		for i in range(min(int(fuel) + 1, 5)):
			$Bars.get_child(i).show()
			$Bars.get_child(i).scale.x = 1.0
		if int(fuel) < 5:
			$Bars.get_child(int(fuel)).scale.x = fuel - int(fuel)
		for i in range(min(int(fuel) + 1, 5), 5):
			$Bars.get_child(i).hide()
			$Bars.get_child(i).scale.x = 1.0
		if fuel == 0:
			if $JetPack.visible:
				$JetPack.hide()
				var tween: Tween = create_tween()
				for i in range(4):
					tween.tween_property(self, "position:y", position.y + 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					tween.tween_property(self, "position:y", position.y - 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position:y", position.y, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_callback(get_parent().get_node("Restart").show)
				for i in range(4):
					tween.tween_property(get_parent().get_node("Restart"), "position:y", get_parent().get_node("Restart").position.y + 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					tween.tween_property(get_parent().get_node("Restart"), "position:y", get_parent().get_node("Restart").position.y - 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(get_parent().get_node("Restart"), "position:y", get_parent().get_node("Restart").position.y, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				get_parent().get_node("OutOfFuelSound").play()
		else:
			$JetPack.show()
			get_parent().get_node("Restart").hide()

func _ready() -> void:
	fuel = fuel
