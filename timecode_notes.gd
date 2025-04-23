extends VBoxContainer

const timecode_note_scene: PackedScene = preload("res://scenes/forms/timecode_note.tscn")

func _ready() -> void:
	get_node("TimecodeNote").text_submitted_or_next.connect(_on_text_submitted_or_next)
	get_node("TimecodeNote").set_line_id(0)

func sort_notes_by_time() -> void:
	var children_notes := get_children()
	children_notes.sort_custom(compare_times)
	for c in get_children():
		remove_child(c)
	for c in children_notes:
		add_child(c)

func compare_times(a, b) -> bool:
	# Exception for a newly created line (which is empty for now)
	if a.line_id == get_child_count()-1:
		return false
	
	# Both lines have some timecode
	if a.has_timecode and b.has_timecode:
		if a.get_hour() < b.get_hour():
			return true
		elif a.get_hour() == b.get_hour():
			if a.get_minute() < b.get_minute():
				return true
			elif a.get_minute() == b.get_minute():
				if a.get_second() < b.get_second():
					return true
				elif a.get_second() == b.get_second():
					if a.get_frame() < b.get_frame():
						return true
					elif a.get_frame() == b.get_frame():
						return a.line_id < b.line_id
	elif not a.has_timecode and b.has_timecode:
		return true
	elif a.has_timecode and not b.has_timecode:
		return false
	elif not a.has_timecode and not b.has_timecode:
		return a.line_id < b.line_id
	
	return false

# Signals -----------------------------------------------------------------------------------------

func _on_text_submitted_or_next(line_id: int) -> void:
	if line_id == get_child_count()-1:
		var new_note = timecode_note_scene.instantiate()
		add_child(new_note)
		new_note.text_submitted_or_next.connect(_on_text_submitted_or_next)
		new_note.set_line_id(get_child_count()-1)
		
		# Go to previous control (coz of automatic tab behavior)
		var event := InputEventKey.new()
		event.pressed = true
		event.keycode = KEY_TAB
		event.shift_pressed = true
		Input.parse_input_event(event)
		
		sort_notes_by_time()
