@tool
extends Button

@export var button_text: String = "": set = set_button_text
var is_emphasized: bool = false

func toggle_emphasis(value: bool) -> void:
	is_emphasized = value
	get_node("Panel").visible = value

func set_button_text(value: String) -> void:
	button_text = value
	get_node("MarginContainer/Label").text = value
