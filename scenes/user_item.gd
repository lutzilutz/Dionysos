class_name UserItem extends Control

signal ask_edition
signal ask_deletion(full_name)

var full_name: String = ""
var phone: String = ""
var email: String = ""

func change_user(new_name: String, new_phone: String, new_email: String) -> void:
	full_name = new_name
	phone = new_phone
	email = new_email
	
	get_node("MarginContainer/UserContainer/UserNameLabel").text = full_name
	get_node("MarginContainer/UserContainer/UserPhoneLabel").text = phone
	get_node("MarginContainer/UserContainer/UserEmailLabel").text = email

func _on_user_edit_button_pressed() -> void:
	pass # Replace with function body.

func _on_user_delete_button_pressed() -> void:
	ask_deletion.emit(full_name)
