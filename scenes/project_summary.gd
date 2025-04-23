extends Control

signal open_folder

func _on_texture_button_pressed() -> void:
	open_folder.emit()
