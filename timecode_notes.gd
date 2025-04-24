extends ScrollContainer

const timecode_note_scene: PackedScene = preload("res://scenes/forms/timecode_note.tscn")

@onready var notes_container = get_node("VBoxContainer")

var main_scene
var edit_manager
var notes: EditNotes = EditNotes.new()

func _ready() -> void:
	notes_container.get_node("TimecodeNote").text_submitted_or_next.connect(_on_text_submitted_or_next)
	notes_container.get_node("TimecodeNote").field_has_changed.connect(_on_field_has_changed)
	notes_container.get_node("TimecodeNote").new_note.connect(_on_new_note)
	notes_container.get_node("TimecodeNote").note_submitted.connect(_on_note_submitted)
	notes_container.get_node("TimecodeNote").note_need_deletion.connect(_on_note_need_deletion)
	notes_container.get_node("TimecodeNote").set_line_id(0)

func init(gparent, parent) -> void:
	main_scene = gparent
	edit_manager = parent
	notes_container.get_node("TimecodeNote").show_ids(main_scene.user_preferences.show_ids)

func sort_notes_by_time() -> void:
	notes_container.get_children().sort_custom(compare_times)

func compare_times(a, b) -> bool:
	# Exception for a newly created line (which is empty for now)
	#if a.note_id == get_child_count()-1:
		#return false
	
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
						return a.note_id < b.note_id
	elif not a.has_timecode() and b.has_timecode():
		return true
	elif a.has_timecode() and not b.has_timecode():
		return false
	elif not a.has_timecode() and not b.has_timecode():
		#print("comparing " + str(a.line_id) + " - " + str(b.line_id))
		return a.note_id < b.note_id
	
	return false

func build_notes_controls():
	if notes.notes.size() == 0:
		PrintUtility.print_info("No notes")
	
	for n in notes_container.get_children():
		n.queue_free()
		await n.tree_exited
	
	if notes_container.get_child_count() > 0:
		PrintUtility.print_error("Notes aren't emptied ! still " + str(notes_container.get_child_count()) + " children")
	
	for i in range(notes.notes.size()):
		var new_note = timecode_note_scene.instantiate()
		new_note.set_text(notes.notes[i].text)
		new_note.set_line_id(notes.notes[i].note_id)
		if notes.notes[i].hour > 0: new_note.get_node("HourEdit").text = str(notes.notes[i].hour)
		if notes.notes[i].minute > 0: new_note.get_node("MinuteEdit").text = str(notes.notes[i].minute)
		if notes.notes[i].second > 0: new_note.get_node("SecondEdit").text = str(notes.notes[i].second)
		if notes.notes[i].frame > 0: new_note.get_node("FrameEdit").text = str(notes.notes[i].frame)
		new_note.show_ids(main_scene.user_preferences.show_ids)
		new_note.text_submitted_or_next.connect(_on_text_submitted_or_next)
		new_note.field_has_changed.connect(_on_field_has_changed)
		new_note.new_note.connect(_on_new_note)
		new_note.update_timecode_visibility()
		new_note.update_new_note_visibility(true)
		notes_container.add_child(new_note)
	
	var new_edit_note = timecode_note_scene.instantiate()
	new_edit_note.show_ids(main_scene.user_preferences.show_ids)
	new_edit_note.text_submitted_or_next.connect(_on_text_submitted_or_next)
	new_edit_note.field_has_changed.connect(_on_field_has_changed)
	new_edit_note.new_note.connect(_on_new_note)
	new_edit_note.set_line_id(notes.get_next_id())
	new_edit_note.update_new_note_visibility(false)
	notes_container.add_child(new_edit_note)
	
	update_hour_slot(edit_manager.use_hour)

func get_next_id() -> void:
	pass

func update_hour_slot(use_hour: bool) -> void:
	for c in notes_container.get_children():
		c.get_node("HourEdit").visible = use_hour

func get_timecode_note(note_id: int) -> TimecodeNote:
	var result: TimecodeNote = null
	for tcn: TimecodeNote in notes_container.get_children():
		if tcn.note_id == note_id:
			result = tcn
	if result == null:
		PrintUtility.print_error("Didn't find TimecodeNote in timecode_notes.get_timecode_note(" + str(note_id) + ")")
	return result

# Signals -----------------------------------------------------------------------------------------

func _on_note_need_deletion(note_id: int) -> void:
	PrintUtility.print_info("TimecodeNotes trying to delete note " + str(note_id))
	if notes.contains_note_id(note_id):
		notes.remove_note_by_id(note_id)
		for tcn in notes_container.get_children():
			if tcn.note_id == note_id:
				tcn.queue_free()
				await tcn.tree_exited
	else:
		PrintUtility.print_error("Didn't find EditNote in timecode_notes.note_need_deletion(" + str(note_id) + ")")

func _on_note_submitted(note_id: int, hour: int, minute: int, second: int, frame: int, text: String) -> void:
	PrintUtility.print_signal("TimecodeNotes recieved note_submitted(" + str(note_id) + ")")
	
	if get_timecode_note(note_id).empty_note:
		PrintUtility.print_info("Managing new note")
		
		# EditNote object (data)
		var note: EditNote = EditNote.new()
		note.note_id = note_id
		note.hour = hour
		note.minute = minute
		note.second = second
		note.frame = frame
		note.text = text
		notes.notes.append(note)
		
		# Controls
		get_timecode_note(note_id).set_empty_note()
		var tcn: TimecodeNote = timecode_note_scene.instantiate()
		notes_container.add_child(tcn)
		tcn.text_submitted_or_next.connect(_on_text_submitted_or_next)
		tcn.field_has_changed.connect(_on_field_has_changed)
		tcn.new_note.connect(_on_new_note)
		tcn.note_submitted.connect(_on_note_submitted)
		tcn.note_need_deletion.connect(_on_note_need_deletion)
		tcn.set_line_id(notes.get_next_id())
	else:
		PrintUtility.print_TODO("Manage existing note (maybe unecessary)")
	
	#if not notes.contains_note_id(note_id):
		#var note: EditNote = EditNote.new()
		#note.note_id = note_id
		#note.hour = hour
		#note.minute = minute
		#note.second = second
		#note.frame = frame
		#note.text = text
		#notes.notes.append(note)
	#else:
		#PrintUtility.print_TODO("Change existing note with new fields in _on_note_submitted")

func _on_new_note(note_id: int) -> void:
	PrintUtility.print_signal("TimecodeNotes recieved new_note(" + str(note_id) + ")")

func _on_field_has_changed(note_id: int, field_id: int, text: String) -> void:
	PrintUtility.print_signal("Field has changed : " + str(note_id) + " - " + str(field_id) + " - " + text)
	
	if not get_timecode_note(note_id).empty_note:
		PrintUtility.print_TODO("Manage existing note update")
		if notes.contains_note_id(note_id):
			var current_note: EditNote = notes.get_note_by_id(note_id)
			print(current_note)
			match field_id:
				0: # Hour
					current_note.hour = int(text)
				1: # Minute
					current_note.minute = int(text)
				2: # Second
					current_note.second = int(text)
				3: # Frame
					current_note.frame = int(text)
				4: # Text
					current_note.text = text
		else:
			PrintUtility.print_error("Didn't find corresponding note id in EditNotes !")
	
	#if not notes.contains_note_id(line_id):
		#var note: EditNote = EditNote.new()
		#note.note_id = notes.get_next_id()
		#notes.notes.append(note)
	#else:
		#PrintUtility.print_TODO("Change existing note with new fields")
	#
	#match field_id:
		#0: # Hour
			#notes.notes[line_id].hour = int(text)
		#1: # Minute
			#notes.notes[line_id].minute = int(text)
		#2: # Second
			#notes.notes[line_id].second = int(text)
		#3: # Frame
			#notes.notes[line_id].frame = int(text)
		#4: # Text
			#notes.notes[line_id].text = text

func _on_text_submitted_or_next(line_id: int) -> void:
	# Save current line
	#var new_note: EditNote = EditNote.new()
	#new_note.text = notes_container.get_child(notes_container.get_child_count()-1).get_node("TextEdit").text
	#new_note.note_id = notes_container.get_child_count()-1
	#new_note.hour = int(notes_container.get_child(notes_container.get_child_count()-1).get_node("HourEdit").text)
	#new_note.minute = int(notes_container.get_child(notes_container.get_child_count()-1).get_node("MinuteEdit").text)
	#new_note.second = int(notes_container.get_child(notes_container.get_child_count()-1).get_node("SecondEdit").text)
	#new_note.frame = int(notes_container.get_child(notes_container.get_child_count()-1).get_node("FrameEdit").text)
	#notes.notes.append(new_note)
	
	#if line_id == notes_container.get_child_count()-1: # is the last line
		
	# Sort notes
	#notes.notes.sort_custom(compare_times)
	#build_notes_controls()
	#print(notes.notes.size())
		
		# Generate new field
		#var new_edit_note = timecode_note_scene.instantiate()
		#notes_container.add_child(new_edit_note)
		#new_edit_note.text_submitted_or_next.connect(_on_text_submitted_or_next)
		#new_edit_note.set_line_id(notes_container.get_child_count()-1)
		
		# Manage scroll and focus
	pass
