extends Control

const MD_Title: PackedScene = preload("res://scenes/md/md_title.tscn")
const MD_Text: PackedScene = preload("res://scenes/md/md_text.tscn")
const MD_Space: PackedScene = preload("res://scenes/md/md_space.tscn")

@export_multiline var text: String

@onready var container = get_node("VBoxContainer")

func parse_md_file() -> void:
	for c in container.get_children():
		c.queue_free()
		await c.tree_exited
	
	var lines = text.split("\n", true, 0)
	var new_paragraph: bool = true
	var current_paragraph = null
	for line: String in lines:
		if line.length() > 0:
			if line[0] == "#":
				new_paragraph = true
				var new_title = MD_Title.instantiate()
				new_title.set_text(remove_heading_prefix(line))
				container.add_child(new_title)
			elif line.begins_with(" - "):
				current_paragraph = MD_Text.instantiate()
				current_paragraph.set_text(line.right(line.length()-3))
				current_paragraph.set_is_list(true)
				container.add_child(current_paragraph)
			elif line == " ":
				new_paragraph = true
			else:
				if new_paragraph:
					container.add_child(MD_Space.instantiate())
					current_paragraph = MD_Text.instantiate()
					current_paragraph.set_text(line)
					container.add_child(current_paragraph)
					new_paragraph = false
				else:
					current_paragraph.append_text(" " + line)
		else:
			new_paragraph = true

func is_empty_line(new_text: String) -> bool:
	return new_text.length() == 0

func remove_heading_prefix(new_text: String) -> String:
	var tmp_splits = new_text.split(" ")
	tmp_splits.remove_at(0)
	return " ".join(tmp_splits)
