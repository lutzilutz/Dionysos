extends ScrollContainer

const timecode_note_scene: PackedScene = preload("res://scenes/forms/timecode_note.tscn")

@onready var notes_container = get_node("VBoxContainer")

var main_scene
var edit_manager
var notes: EditNotes = EditNotes.new()

func _ready() -> void:
	notes_container.get_node("TimecodeNote").field_has_changed.connect(_on_field_has_changed)
	notes_container.get_node("TimecodeNote").note_submitted.connect(_on_note_submitted)
	notes_container.get_node("TimecodeNote").note_need_deletion.connect(_on_note_need_deletion)
	notes_container.get_node("TimecodeNote").set_line_id(0)

func init(gparent, parent) -> void:
	main_scene = gparent
	edit_manager = parent
	notes_container.get_node("TimecodeNote").show_ids(main_scene.user_preferences.show_ids)
	update_hour_slot(edit_manager.use_hour)

func sort_notes_by_time() -> void:
	notes.sort_notes_by_time()
	update_sort_order()
	PrintUtility.print_info("Notes have been sorted by time")

func update_sort_order() -> void:
	for i in range(notes.notes.size()):
		var current_tcn: TimecodeNote = null
		for tcn in notes_container.get_children():
			if tcn.note_id == notes.notes[i].note_id:
				current_tcn = tcn
		notes_container.move_child(current_tcn, i)

func rebuild_notes_controls():
	if notes.notes.size() == 0:
		PrintUtility.print_info("No notes to rebuild")
	
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
		new_note.field_has_changed.connect(_on_field_has_changed)
		new_note.update_timecode_visibility()
		new_note.set_empty_note()
		notes_container.add_child(new_note)
	
	var new_edit_note = timecode_note_scene.instantiate()
	new_edit_note.show_ids(main_scene.user_preferences.show_ids)
	new_edit_note.field_has_changed.connect(_on_field_has_changed)
	new_edit_note.set_line_id(notes.get_next_id())
	#new_edit_note.set_empty_note()
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
		tcn.field_has_changed.connect(_on_field_has_changed)
		tcn.note_submitted.connect(_on_note_submitted)
		tcn.note_need_deletion.connect(_on_note_need_deletion)
		tcn.set_line_id(notes.get_next_id())
		tcn.get_node("TextEdit").grab_focus()
		update_hour_slot(edit_manager.use_hour)
	else:
		PrintUtility.print_TODO("Manage existing note (maybe unecessary)")

func _on_new_note(note_id: int) -> void:
	PrintUtility.print_signal("TimecodeNotes recieved new_note(" + str(note_id) + ")")

func _on_field_has_changed(note_id: int, field_id: int, text: String) -> void:
	PrintUtility.print_signal("Field has changed : " + str(note_id) + " - " + str(field_id) + " - " + text)
	
	if not get_timecode_note(note_id).empty_note:
		if notes.contains_note_id(note_id):
			var current_note: EditNote = notes.get_note_by_id(note_id)
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
