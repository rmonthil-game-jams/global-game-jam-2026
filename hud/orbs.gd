extends Node3D

const WIN_NUMBER: int = 9

var tween: Tween
var position_y: float = 0.0

var number: int = 0:
	set(value):
		var new_number: int = max(value, 0)
		if new_number != number:
			number = new_number
			if number >= WIN_NUMBER:
				$Label3D.text = str(number) + "/" + "??"
			else:
				$Label3D.text = str(number) + "/" + str(WIN_NUMBER)
			if number == WIN_NUMBER: # WIN
				$AudioStreamPlayerWin.play()
				get_parent().get_node("TimerFixed").update()
				get_parent().get_node("TimerFixed").show()
				var tween_more: Tween = create_tween()
				for i in range(4):
					tween_more.tween_property(get_parent().get_node("TimerFixed"), "position:y", get_parent().get_node("TimerFixed").position.y + 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					tween_more.tween_property(get_parent().get_node("TimerFixed"), "position:y", get_parent().get_node("TimerFixed").position.y - 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween_more.tween_property(get_parent().get_node("TimerFixed"), "position:y", get_parent().get_node("TimerFixed").position.y, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				# TODO: WIN ANIMATION
			if tween:
				tween.stop()
				position.y = position_y
			position_y = position.y
			tween = create_tween()
			for i in range(4):
				tween.tween_property(self, "position:y", position.y + 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position:y", position.y - 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(self, "position:y", position.y, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			$AudioStreamPlayerLoot.play()

func _ready() -> void:
	number = number
	$Label3D.text = str(number) + "/" + str(WIN_NUMBER)
