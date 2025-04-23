extends ScrollContainer

const timecode_note_scene: PackedScene = preload("res://scenes/forms/timecode_note.tscn")

@onready var notes_container = get_node("VBoxContainer")

var notes: EditNotes = EditNotes.new()

func _ready() -> void:
	notes_container.get_node("TimecodeNote").text_submitted_or_next.connect(_on_text_submitted_or_next)
	notes_container.get_node("TimecodeNote").set_line_id(0)

func sort_notes_by_time() -> void:
	notes_container.get_children().sort_custom(compare_times)

func compare_times(a, b) -> bool:
	# Exception for a newly created line (which is empty for now)
	if a.line_id == get_child_count()-1:
		return false
	
	# Both lines have some timecode
	if a.has_timecode() and b.has_timecode():
		if a.hour < b.hour:
			return true
		elif a.hour == b.hour:
			if a.minute < b.minute:
				return true
			elif a.minute == b.minute:
				if a.second < b.second:
					return true
				elif a.second == b.second:
					if a.frame < b.frame:
						return true
					elif a.frame == b.frame:
						return a.line_id < b.line_id
	elif not a.has_timecode() and b.has_timecode():
		return true
	elif a.has_timecode() and not b.has_timecode():
		return false
	elif not a.has_timecode() and not b.has_timecode():
		#print("comparing " + str(a.line_id) + " - " + str(b.line_id))
		return a.line_id < b.line_id
	
	return false

func build_notes_controls():
	if notes.notes.size() == 0:
		PrintUtility.print_info("No notes")
	
	for n in notes_container.get_children():
		n.queue_free()
		await n.tree_exited
	
	for i in range(notes.notes.size()):
		var new_note = timecode_note_scene.instantiate()
		new_note.set_text(notes.notes[i].text)
		new_note.set_line_id(notes.notes[i].line_id)
		if notes.notes[i].hour > 0: new_note.get_node("HourEdit").text = str(notes.notes[i].hour)
		if notes.notes[i].minute > 0: new_note.get_node("MinuteEdit").text = str(notes.notes[i].minute)
		if notes.notes[i].second > 0: new_note.get_node("SecondEdit").text = str(notes.notes[i].second)
		if notes.notes[i].frame > 0: new_note.get_node("FrameEdit").text = str(notes.notes[i].frame)
		#print(notes.notes[i].frame)
		notes_container.add_child(new_note)
	
	
	var new_edit_note = timecode_note_scene.instantiate()
	notes_container.add_child(new_edit_note)
	new_edit_note.text_submitted_or_next.connect(_on_text_submitted_or_next)
	new_edit_note.set_line_id(notes_container.get_child_count()-1)

# Signals -----------------------------------------------------------------------------------------

func _on_text_submitted_or_next(line_id: int) -> void:
	# Save current line
	var new_note: EditNote = EditNote.new()
	new_note.text = notes_container.get_child(notes_container.get_child_count()-1).get_node("TextEdit").text
	new_note.line_id = notes_container.get_child_count()-1
	new_note.hour = int(notes_container.get_child(notes_container.get_child_count()-1).get_node("HourEdit").text)
	new_note.minute = int(notes_container.get_child(notes_container.get_child_count()-1).get_node("MinuteEdit").text)
	new_note.second = int(notes_container.get_child(notes_container.get_child_count()-1).get_node("SecondEdit").text)
	new_note.frame = int(notes_container.get_child(notes_container.get_child_count()-1).get_node("FrameEdit").text)
	notes.notes.append(new_note)
	
	if line_id == notes_container.get_child_count()-1: # is the last line
		
		# Sort notes
		notes.notes.sort_custom(compare_times)
		build_notes_controls()
		#print(notes.notes.size())
		
		# Generate new field
		#var new_edit_note = timecode_note_scene.instantiate()
		#notes_container.add_child(new_edit_note)
		#new_edit_note.text_submitted_or_next.connect(_on_text_submitted_or_next)
		#new_edit_note.set_line_id(notes_container.get_child_count()-1)
		
		# Manage scroll and focus
		

func _on_text_submitted_or_next_OLD(line_id: int) -> void:
	if line_id == get_node("VBoxContainer").get_child_count()-1: # is the last line
		
		#sort_notes_by_time()
		
		var new_note = timecode_note_scene.instantiate()
		get_node("VBoxContainer").add_child(new_note)
		new_note.text_submitted_or_next.connect(_on_text_submitted_or_next)
		new_note.set_line_id(get_node("VBoxContainer").get_child_count()-1)
		
		new_note.get_node("TextEdit").grab_focus.call_deferred()
		set_deferred("scroll_vertical", 20*scroll_vertical + 10000)
		
		# Go to previous control (coz of automatic tab behavior)
		#var event := InputEventKey.new()
		#event.pressed = true
		#event.keycode = KEY_TAB
		#event.shift_pressed = true
		#Input.parse_input_event(event)
		
