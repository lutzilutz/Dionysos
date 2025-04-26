class_name EditNotes extends Node

var notes: Array = []

func sort_notes_by_time() -> void:
	notes.sort_custom(compare_times)

func compare_times(a, b) -> bool:
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
		return a.note_id < b.note_id
	
	return false

func get_next_id() -> int:
	var ids: Array = []
	for n in notes:
		ids.append(n.note_id)
	ids.sort()
	var next_id: int = 0
	for id in ids:
		if id != next_id:
			break
		else:
			next_id += 1
	return next_id

func contains_note_id(new_id: int) -> bool:
	for n in notes:
		if n.note_id == new_id:
			return true
	return false

func get_note_by_id(new_id: int) -> EditNote:
	var result: EditNote = null
	for n: EditNote in notes:
		if n.note_id == new_id:
			result = n
	if result == null:
		PrintUtility.print_error("Couldn't retrieve EditNote id=" + str(new_id) + " in EditNotes.get_note_by_id()")
	return result

func remove_note_by_id(new_id: int) -> void:
	var index_to_delete: int = -1
	for i in range(notes.size()):
		if notes[i].note_id == new_id:
			index_to_delete = i
	
	if index_to_delete == -1:
		PrintUtility.print_error("Couldn't find note to delete")
	else:
		notes.remove_at(index_to_delete)
