class_name TimecodeNote extends HBoxContainer

signal note_submitted(note_id: int, hour: int, minute: int, second: int, frame: int, text: String)
signal field_has_changed(line_id: int, field_id: int, text: String)
signal note_need_deletion(note_id: int)

var empty_note: bool = true
var note_id: int = 0

func _ready() -> void:
	modulate = Color(1,1,1,0.5)

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

func set_empty_note() -> void:
	if empty_note:
		modulate = Color(1,1,1,1)
	empty_note = false

func set_text(new_text: String) -> void:
	get_node("TextEdit").text = new_text

func set_line_id(new_id: int) -> void:
	note_id = new_id
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
	note_submitted.emit(note_id, int(get_node("HourEdit").text), int(get_node("MinuteEdit").text), int(get_node("SecondEdit").text), int(get_node("FrameEdit").text), new_text)

func _on_hour_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(note_id, 0, new_text)

func _on_minute_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(note_id, 1, new_text)

func _on_second_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(note_id, 2, new_text)

func _on_frame_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(note_id, 3, new_text)

func _on_text_edit_text_changed(new_text: String) -> void:
	field_has_changed.emit(note_id, 4, new_text)

func _on_delete_button_pressed() -> void:
	if empty_note:
		get_node("HourEdit").text = ""
		get_node("MinuteEdit").text = ""
		get_node("SecondEdit").text = ""
		get_node("FrameEdit").text = ""
		get_node("TextEdit").text = ""
	else:
		note_need_deletion.emit(note_id)
