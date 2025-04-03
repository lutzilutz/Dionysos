extends Control

signal users_changed

var main_scene
var modified_user: int = -1
var is_new_user: bool = false

var UserItem = preload("res://scenes/user_item.tscn")
@onready var users_container = get_node("VBoxContainer/UsersScroll/UsersVBox")

func build_users() -> void:
	if main_scene.user_preferences.editors.size() == 0:
		print("No user")
	
	for u in users_container.get_children():
		if u.name != "NewButton":
			u.queue_free()
	
	for i in range(main_scene.user_preferences.editors.size()):
		var tmp_user = UserItem.instantiate()
		tmp_user.change_user(i, main_scene.user_preferences.editors[i].name, main_scene.user_preferences.editors[i].phone, main_scene.user_preferences.editors[i].email)
		tmp_user.ask_edition.connect(_on_user_item_ask_edition)
		tmp_user.ask_deletion.connect(_on_user_item_ask_deletion)
		users_container.add_child(tmp_user)
	
	users_container.move_child(get_node("VBoxContainer/UsersScroll/UsersVBox/NewButton"), get_node("VBoxContainer/UsersScroll/UsersVBox").get_child_count()-1)

func _on_close_button_pressed() -> void:
	main_scene.build_editor_options()
	main_scene.editor_name = ""
	main_scene.update_controls()
	self.visible = false

func _on_user_item_ask_edition(index: int) -> void:
	modified_user = index
	get_node("VBoxContainer/ModifyPanel/NameEdit").text = main_scene.user_preferences.editors[modified_user].name
	get_node("VBoxContainer/ModifyPanel/NameEdit").editable = false
	get_node("VBoxContainer/ModifyPanel/PhoneEdit").text = main_scene.user_preferences.editors[modified_user].phone
	get_node("VBoxContainer/ModifyPanel/EmailEdit").text = main_scene.user_preferences.editors[modified_user].email
	get_node("VBoxContainer/ModifyPanel").visible = true

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
	if get_node("VBoxContainer/ModifyPanel/NameEdit").text == "":
		issue_found = true
		get_node("AcceptDialog2").visible = true
	
	if not is_new_user:
		PrintUtility.print_info("Try editing existing user")
	else:
		if main_scene.user_preferences.editor_exists(get_node("VBoxContainer/ModifyPanel/NameEdit").text) :
			issue_found = true
			update_modification_dialog()
			get_node("ConfirmationDialog").visible = true
		else:
			if not issue_found:
				main_scene.user_preferences.add_editor(get_node("VBoxContainer/ModifyPanel/NameEdit").text, get_node("VBoxContainer/ModifyPanel/PhoneEdit").text, get_node("VBoxContainer/ModifyPanel/EmailEdit").text)
				is_new_user = false
	
	if not issue_found:
		main_scene.user_preferences.save_to_file(main_scene.USER_PREF_PATH)
		modified_user = -1
		build_users()
		get_node("VBoxContainer/ModifyPanel").visible = false

func update_modification_dialog() -> void:
	get_node("ConfirmationDialog/VBoxContainer/Label").text = "L'utilisateur \"" + get_node("VBoxContainer/ModifyPanel/NameEdit").text + "\" est déjà présent. Les modifications suivantes seront apportées :"
	get_node("ConfirmationDialog/VBoxContainer/Label2").text = ""
	var current_editor = main_scene.user_preferences.get_editor_from_name(get_node("VBoxContainer/ModifyPanel/NameEdit").text)
	
	if get_node("VBoxContainer/ModifyPanel/NameEdit").text != current_editor.name:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "Nom : " + current_editor.name + " -> " + get_node("VBoxContainer/ModifyPanel/NameEdit").text + "\n"
	else:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "\n"
	
	if get_node("VBoxContainer/ModifyPanel/PhoneEdit").text != current_editor.phone:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "Téléphone : " + current_editor.phone + " -> " + get_node("VBoxContainer/ModifyPanel/PhoneEdit").text + "\n"
	else:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "\n"
	
	if get_node("VBoxContainer/ModifyPanel/EmailEdit").text != current_editor.email:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "E-mail : " + current_editor.email + " -> " + get_node("VBoxContainer/ModifyPanel/EmailEdit").text

func _on_cancel_button_pressed() -> void:
	modified_user = -1
	get_node("VBoxContainer/ModifyPanel").visible = false
	is_new_user = false

func _on_new_button_pressed() -> void:
	is_new_user = true
	get_node("VBoxContainer/ModifyPanel/NameEdit").editable = true
	get_node("VBoxContainer/ModifyPanel/NameEdit").text = ""
	get_node("VBoxContainer/ModifyPanel/PhoneEdit").text = ""
	get_node("VBoxContainer/ModifyPanel/EmailEdit").text = ""
	get_node("VBoxContainer/ModifyPanel").visible = true

func _on_confirmation_dialog_confirmed() -> void:
	main_scene.user_preferences.change_editor(get_node("VBoxContainer/ModifyPanel/NameEdit").text, get_node("VBoxContainer/ModifyPanel/PhoneEdit").text, get_node("VBoxContainer/ModifyPanel/EmailEdit").text)
	main_scene.user_preferences.save_to_file(main_scene.USER_PREF_PATH)
	modified_user = -1
	build_users()
	get_node("VBoxContainer/ModifyPanel").visible = false

func _on_confirmation_dialog_canceled() -> void:
	pass # Replace with function body.
