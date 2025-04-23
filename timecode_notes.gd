extends VBoxContainer

const timecode_note_scene: PackedScene = preload("res://scenes/forms/timecode_note.tscn")

func _ready() -> void:
	get_node("TimecodeNote").text_submitted_or_next.connect(_on_text_submitted_or_next)

func _on_text_submitted_or_next() -> void:
	var new_note = timecode_note_scene.instantiate()
	add_child(new_note)
	new_note.text_submitted_or_next.connect(_on_text_submitted_or_next)
	#new_note.get_node("TextEdit").grab_focus()
	print("new line")
	pass
