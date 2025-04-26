extends HBoxContainer

var is_list: bool = false

func append_text(new_text: String) -> void:
	get_node("TextLabel").text += new_text

func set_text(new_text: String) -> void:
	get_node("TextLabel").text = new_text

func set_is_list(new_is_list: bool) -> void:
	is_list = new_is_list
	get_node("ListLabel").visible = is_list
