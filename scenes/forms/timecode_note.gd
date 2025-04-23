extends HBoxContainer

signal text_submitted_or_next

func _on_text_edit_text_submitted(new_text: String) -> void:
	text_submitted_or_next.emit()

func _on_text_edit_focus_exited() -> void:
	if get_node("TextEdit").text != "":
		text_submitted_or_next.emit()
