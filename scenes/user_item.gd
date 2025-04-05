class_name UserItem extends Control

const user_item: PackedScene = preload("res://scenes/user_item.tscn")

signal ask_edition(index)
signal ask_deletion(index)

var pref_index: int = -1 # index from user_preferences.editors array
var user_function: DataManager.UserFunction = DataManager.UserFunction.UNKNOWN
var full_name: String = ""
var phone: String = ""
var email: String = ""

func change_user(index: int, new_function: DataManager.UserFunction, new_name: String, new_phone: String, new_email: String) -> void:
	pref_index = index
	user_function = new_function
	full_name = new_name
	phone = new_phone
	email = new_email
	
	get_node("Button/MarginContainer/UserContainer/UserNameLabel").text = full_name
	get_node("Button/MarginContainer/UserContainer/UserPhoneLabel").text = phone
	get_node("Button/MarginContainer/UserContainer/UserEmailLabel").text = email

static func new_user(index: int, new_function: DataManager.UserFunction, new_name: String, new_phone: String, new_email: String) -> UserItem:
	var user: UserItem = user_item.instantiate()
	user.change_user(index, new_function, new_name, new_phone, new_email)
	return user

# Setget ==========================================================================================

func emphasized(is_emphasized: bool) -> void:
	if is_emphasized:
		get_node("Button/Emphasis").visible = true
	else:
		get_node("Button/Emphasis").visible = false

# Signals =========================================================================================


#func _on_user_edit_button_pressed() -> void:
	#ask_edition.emit(pref_index)
#
#func _on_user_delete_button_pressed() -> void:
	#ask_deletion.emit(pref_index)

func _on_delete_button_pressed() -> void:
	emphasized(true)
	ask_deletion.emit(pref_index)

func _on_button_pressed() -> void:
	emphasized(true)
	ask_edition.emit(pref_index)
