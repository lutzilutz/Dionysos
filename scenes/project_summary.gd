extends Control

signal open_folder

func _on_texture_button_pressed() -> void:
	open_folder.emit()

func set_project_name(name: String) -> void:
	get_node("VBoxContainer/HBoxContainer/ProjectName").text = name

func set_customer_name(name: String) -> void:
	get_node("VBoxContainer/HBoxContainer/CustomerName").text = name

func set_version_name(name: String) -> void:
	get_node("VBoxContainer/HBoxContainer2/Version").text = name
