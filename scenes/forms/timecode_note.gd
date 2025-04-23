extends HBoxContainer

signal text_submitted_or_next(line_id)

var line_id: int = 0

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
