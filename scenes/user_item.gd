class_name UserItem extends Control

const user_item_scene: PackedScene = preload("res://scenes/user_item.tscn")
const data_manager_script = preload("res://scripts/data_manager.gd")

signal ask_edition(user)
signal ask_deletion(user)

var user: User

func change_user(new_user: User) -> void:
	user = new_user
	update_controls(new_user)

func update_controls(new_user) -> void:
	get_node("Button/MarginContainer/UserContainer/UserNameLabel").text = new_user.name
	get_node("Button/MarginContainer/UserContainer/UserPhoneLabel").text = new_user.phone
	get_node("Button/MarginContainer/UserContainer/UserEmailLabel").text = new_user.email
	get_node("Button/MarginContainer/UserContainer/UserFunctionLabel").text = data_manager_script.user_function_plain_text(new_user.function)

# Setget ==========================================================================================

func set_user(new_user: User) -> void:
	user = new_user
	update_controls(new_user)

func emphasized(is_emphasized: bool) -> void:
	if is_emphasized:
		get_node("Button/Emphasis").visible = true
	else:
		get_node("Button/Emphasis").visible = false

# Signals =========================================================================================

func _on_delete_button_pressed() -> void:
	emphasized(true)
	ask_deletion.emit(user)

func _on_button_pressed() -> void:
	emphasized(true)
	ask_edition.emit(user)
