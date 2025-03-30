extends Label

func disable(state: bool) -> void:
	if state:
		modulate = Color(1,1,1,0.25)
	else:
		modulate = Color(1,1,1,1)
