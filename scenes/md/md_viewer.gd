@tool
extends Control

const MD_Title: PackedScene = preload("res://scenes/md/md_title.tscn")
const MD_Text: PackedScene = preload("res://scenes/md/md_text.tscn")

@export_multiline var text: String

@onready var container = get_node("VBoxContainer")

func _ready() -> void:
	parse_md_file()

func parse_md_file() -> void:
	for c in container.get_children():
		c.queue_free()
		await c.tree_exited
	var lines = text.split("\n")
	var new_paragraph: bool = true
	var current_paragraph = null
	var previous_line_empty: bool = false
	for line: String in lines:
		if line.length() > 0:
			if line[0] == "#":
				#PrintUtility.print_info("Line is a title : " + line)
				new_paragraph = true
				var new_title = MD_Title.instantiate()
				new_title.text = remove_heading_prefix(line)
				container.add_child(new_title)
				previous_line_empty = false
			#elif line[0] == " " and line[1] == "-":
				#PrintUtility.print_info("Line is list : " + line)
				#new_paragraph = true
				#previous_line_empty = false
			else:
				#PrintUtility.print_info("Line is text : " + line)
				if new_paragraph:
					current_paragraph = MD_Text.instantiate()
					current_paragraph.text = ""
					container.add_child(current_paragraph)
					new_paragraph = false
					current_paragraph.text += line
				else:
					if previous_line_empty:
						current_paragraph.text += "\n"
					current_paragraph.text += "\n" + line
			previous_line_empty = false
		else:
			previous_line_empty = true

func remove_heading_prefix(new_text: String) -> String:
	var tmp_splits = new_text.split(" ")
	tmp_splits.remove_at(0)
	return " ".join(tmp_splits)
