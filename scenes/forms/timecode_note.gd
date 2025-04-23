extends HBoxContainer

signal text_submitted_or_next(line_id: int)
signal field_has_changed(line_id: int, field_id: int, text: String)

var line_id: int = 0

func show_ids(show_ids) -> void:
	get_node("Label").visible = show_ids

func update_timecode_visibility() -> void:
	if has_timecode():
		pass
	else:
		get_node("HourEdit").modulate = Color(1,1,1,0.25)
		get_node("MinuteEdit").modulate = Color(1,1,1,0.25)
		get_node("SecondEdit").modulate = Color(1,1,1,0.25)
		get_node("FrameEdit").modulate = Color(1,1,1,0.25)

func set_text(new_text: String) -> void:
	get_node("TextEdit").text = new_text

func set_line_id(new_id: int) -> void:
	line_id = new_id
	get_node("Label").text = str(new_id)

func get_hour() -> int:
	if get_node("HourEdit").text != "":
		return int(get_node("HourEdit").text)
	else:
		return 0

func get_minute() -> int:
	if get_node("MinuteEdit").text != "":
		return int(get_node("MinuteEdit").text)
	else:
		return 0

func get_second() -> int:
	if get_node("SecondEdit").text != "":
		return int(get_node("SecondEdit").text)
	else:
		return 0

func get_frame() -> int:
	if get_node("FrameEdit").text != "":
		return int(get_node("FrameEdit").text)
	else:
		return 0

func has_timecode() -> bool:
	if get_node("HourEdit").text != "" or get_node("MinuteEdit").text != "" or get_node("SecondEdit").text != "" or get_node("FrameEdit").text != "":
		return true
	return false

# Signals -----------------------------------------------------------------------------------------

func _on_text_edit_text_submitted(new_text: String) -> void:
	text_submitted_or_next.emit(line_id)

func _on_text_edit_focus_exited() -> void:
	if get_node("TextEdit").text != "":
		text_submitted_or_next.emit(line_id)

func _on_hour_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(line_id, 0, new_text)

func _on_minute_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(line_id, 1, new_text)

func _on_second_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(line_id, 2, new_text)

func _on_frame_edit_text_changed(new_text: String) -> void:
	#print("frame changed")
	field_has_changed.emit(line_id, 3, new_text)

func _on_text_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(line_id, 4, new_text)
