extends Node3D

var tween: Tween
var position_y: float = 0.0
var life: int = 7:
	set(value):
		var new_life: int = min(max(value, 0), 7)
		var is_damage: bool = new_life < life
		if new_life != life:
			life = new_life
			for i in range(min(life, 7)):
				$Bars.get_child(i).show()
			for i in range(min(life, 7), 7):
				$Bars.get_child(i).hide()
			if life == 0:
				$Heart.hide()
				# TODO : Animation
				get_tree().root.get_node("Game").restart()
			else:
				$Heart.show()
				if tween:
					tween.stop()
					position.y = position_y
				position_y = position.y
				if is_damage:
					get_parent().get_node("CPUParticles3D").emitting = true
					get_parent().get_parent().get_node("FallDamageSound").play()
					$HeartHurt.show()
					$BarsHurt.show()
					$Bars.hide()
					$Heart.hide()
					$BarsEmpty.hide()
					$HeartEmpty.hide()
				tween = create_tween()
				for i in range(4):
					tween.tween_property(self, "position:y", position.y + 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
					tween.tween_property(self, "position:y", position.y - 0.75, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "position:y", position.y, 5e-2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
				await tween.finished
				if is_damage:
					$HeartHurt.hide()
					$BarsHurt.hide()
					$Bars.show()
					$Heart.show()
					$BarsEmpty.show()
					$HeartEmpty.show()

func _ready() -> void:
	life = life
