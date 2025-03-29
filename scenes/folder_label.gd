extends Label

var tween: Tween
var delay: float = 0

func _ready() -> void:
	self.modulate = Color(1,1,1,0)

func activate() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	offset_left = 50
	modulate = Color(1,1,1,0)
	tween.tween_interval(delay)
	tween.tween_property(self, "offset_left", 0, 1)
	tween.parallel().tween_property(self, "modulate", Color(1,1,1,1), 1)
