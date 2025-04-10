extends Label

var is_disabled: bool = false

func disable(state: bool) -> void:
	is_disabled = state
	if is_disabled:
		modulate = Color(1,1,1,0.25)
	else:
		modulate = Color(1,1,1,1)
