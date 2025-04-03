extends Control

signal ask_edition(index)
signal ask_deletion(index)

var pref_index: int = -1
var full_name: String = ""
var phone: String = ""
var email: String = ""

func change_user(index: int, new_name: String, new_phone: String, new_email: String) -> void:
	pref_index = index
	full_name = new_name
	phone = new_phone
	email = new_email
	
	get_node("MarginContainer/UserContainer/UserNameLabel").text = full_name
	get_node("MarginContainer/UserContainer/UserPhoneLabel").text = phone
	get_node("MarginContainer/UserContainer/UserEmailLabel").text = email

func _on_user_edit_button_pressed() -> void:
	ask_edition.emit(pref_index)

func _on_user_delete_button_pressed() -> void:
	ask_deletion.emit(pref_index)
