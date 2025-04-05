extends Control

signal users_changed

var main_scene
var modified_user: int = -1
var is_new_user: bool = false

#const UserItem = preload("res://scenes/user_item.tscn")
@onready var users_container = get_node("VBoxContainer/UsersScroll/VBoxContainer/UsersVBox")
@onready var panel = get_node("VBoxContainer/Panel")
@onready var modify_panel = panel.get_node("MarginContainer/ModifyPanel")
@onready var name_edit = modify_panel.get_node("NameEdit")
@onready var phone_edit = modify_panel.get_node("PhoneEdit")
@onready var email_edit = modify_panel.get_node("EmailEdit")

func build_users() -> void:
	if main_scene.user_preferences.editors.size() == 0:
		print("No user")
	
	for u in users_container.get_children():
		if u is UserItem:
			u.queue_free()
		else:
			PrintUtility.print_error("Unknown item in user manager spreadsheet : " + u.name)
	
	var users: Array = main_scene.user_preferences.editors.duplicate(true)
	users.sort_custom(compare_user_name)
	
	for i in range(users.size()):
		var tmp_user: UserItem = UserItem.new_user(
			i,
			DataManager.UserFunction.EDITOR,
			users[i].name,
			users[i].phone,
			users[i].email)
		#tmp_user.change_user(i, DataManager.UserFunction.EDITOR, main_scene.user_preferences.editors[i].name, main_scene.user_preferences.editors[i].phone, main_scene.user_preferences.editors[i].email)
		tmp_user.ask_edition.connect(_on_user_item_ask_edition)
		tmp_user.ask_deletion.connect(_on_user_item_ask_deletion)
		users_container.add_child(tmp_user)
	
	#users_container.move_child(get_node("VBoxContainer/UsersScroll/UsersVBox/NewButton"), get_node("VBoxContainer/UsersScroll/UsersVBox").get_child_count()-1)

func compare_user_name(a, b) -> bool:
	if a.name.capitalize() < b.name.capitalize():
		return true
	else:
		return false

func reset_emphasis(index_avoided: int) -> void:
	for u in users_container.get_children():
		if u is UserItem:
			if u.pref_index != index_avoided:
				u.emphasized(false)

func _on_user_item_ask_edition(index: int) -> void:
	reset_emphasis(index)
	modified_user = index
	name_edit.text = main_scene.user_preferences.editors[modified_user].name
	name_edit.editable = false
	phone_edit.text = main_scene.user_preferences.editors[modified_user].phone
	email_edit.text = main_scene.user_preferences.editors[modified_user].email
	panel.visible = true

func _on_user_item_ask_deletion(index: int) -> void:
	modified_user = index
	get_node("AcceptDialog/Label").text = "L'utilisateur \"" + main_scene.user_preferences.editors[modified_user].name + "\" sera définitivement supprimé, non-reversible.\nVoulez-vous le supprimer ?"
	get_node("AcceptDialog").visible = true

func _on_accept_dialog_confirmed() -> void:
	main_scene.user_preferences.remove_editor(modified_user)
	main_scene.user_preferences.save_to_file(main_scene.USER_PREF_PATH)
	build_users()
	users_changed.emit()
	modified_user = -1

func _on_accept_dialog_canceled() -> void:
	pass # Replace with function body.

func _on_save_button_pressed() -> void:
	var issue_found: bool = false
	if name_edit.text == "":
		issue_found = true
		get_node("AcceptDialog2").visible = true
	
	if not is_new_user:
		PrintUtility.print_info("Try editing existing user")
		#update_modification_dialog()
		#get_node("ConfirmationDialog").visible = true
	else:
		if main_scene.user_preferences.editor_exists(name_edit.text) :
			issue_found = true
			update_modification_dialog()
			get_node("ConfirmationDialog").visible = true
		else:
			if not issue_found:
				main_scene.user_preferences.add_editor(name_edit.text, phone_edit.text, email_edit.text)
				is_new_user = false
	
	if not issue_found:
		main_scene.user_preferences.change_editor(name_edit.text, phone_edit.text, email_edit.text)
		main_scene.user_preferences.save_to_file(main_scene.USER_PREF_PATH)
		modified_user = -1
		build_users()
		panel.visible = false
		users_changed.emit()

func update_modification_dialog() -> void:
	get_node("ConfirmationDialog/VBoxContainer/Label").text = "L'utilisateur \"" + name_edit.text + "\" est déjà présent. Les modifications suivantes seront apportées :"
	get_node("ConfirmationDialog/VBoxContainer/Label2").text = ""
	var current_editor = main_scene.user_preferences.get_editor_from_name(name_edit.text)
	
	if name_edit.text != current_editor.name:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "Nom : " + current_editor.name + " -> " + name_edit.text + "\n"
	else:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "\n"
	
	if phone_edit.text != current_editor.phone:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "Téléphone : " + current_editor.phone + " -> " + phone_edit.text + "\n"
	else:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "\n"
	
	if email_edit.text != current_editor.email:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "E-mail : " + current_editor.email + " -> " + email_edit.text

func _on_cancel_button_pressed() -> void:
	modified_user = -1
	panel.visible = false
	is_new_user = false

func _on_new_button_pressed() -> void:
	is_new_user = true
	name_edit.editable = true
	name_edit.text = ""
	phone_edit.text = ""
	email_edit.text = ""
	panel.visible = true

func _on_confirmation_dialog_confirmed() -> void:
	main_scene.user_preferences.change_editor(name_edit.text, phone_edit.text, email_edit.text)
	main_scene.user_preferences.save_to_file(main_scene.USER_PREF_PATH)
	modified_user = -1
	build_users()
	panel.visible = false

func _on_confirmation_dialog_canceled() -> void:
	pass # Replace with function body.
