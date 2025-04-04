extends Control

signal users_changed

var main_scene
var modified_user: int = -1
var is_new_user: bool = false

@onready var users_container = get_node("VBoxContainer/UsersScroll/VBoxContainer/UsersVBox")
@onready var panel = get_node("VBoxContainer/Panel")
@onready var modify_panel = panel.get_node("MarginContainer/ModifyPanel")
@onready var name_edit = modify_panel.get_node("NameEdit")
@onready var phone_edit = modify_panel.get_node("PhoneEdit")
@onready var email_edit = modify_panel.get_node("EmailEdit")
@onready var function_edit = modify_panel.get_node("FunctionOption")

func _ready() -> void:
	function_edit.selected = -1

func build_users() -> void:
	if main_scene.users.all_users.size() == 0:
		PrintUtility.print_info("No user")
	
	for u in users_container.get_children():
		if u is UserItem:
			u.queue_free()
		else:
			PrintUtility.print_error("Unknown item in user manager spreadsheet : " + u.name)
	
	var users: Array = main_scene.users.all_users.duplicate(true)
	
	for i in range(users.size()):
		var tmp_user: UserItem = UserItem.new_user(
			i,
			users[i].function,
			users[i].name,
			users[i].phone,
			users[i].email)
		#tmp_user.change_user(i, DataManager.UserFunction.EDITOR, main_scene.user_preferences.editors[i].name, main_scene.user_preferences.editors[i].phone, main_scene.user_preferences.editors[i].email)
		tmp_user.ask_edition.connect(_on_user_item_ask_edition)
		tmp_user.ask_deletion.connect(_on_user_item_ask_deletion)
		users_container.add_child(tmp_user)
	
	#sort_users()
	
	#users_container.move_child(get_node("VBoxContainer/UsersScroll/UsersVBox/NewButton"), get_node("VBoxContainer/UsersScroll/UsersVBox").get_child_count()-1)

func sort_users() -> void:
	pass

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
	name_edit.text = main_scene.users.editors[modified_user].name
	name_edit.editable = false
	phone_edit.text = main_scene.users.editors[modified_user].phone
	email_edit.text = main_scene.users.editors[modified_user].email
	panel.visible = true

func _on_user_item_ask_deletion(index: int) -> void:
	modified_user = index
	get_node("AcceptDialog/Label").text = "L'utilisateur \"" + main_scene.users.editors[modified_user].name + "\" sera définitivement supprimé, non-reversible.\nVoulez-vous le supprimer ?"
	get_node("AcceptDialog").visible = true

func _on_accept_dialog_confirmed() -> void:
	main_scene.users.remove_editor(modified_user)
	main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
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
		if main_scene.users.editor_exists(name_edit.text) or main_scene.users.customer_exists(name_edit.text):
			issue_found = true
			update_modification_dialog()
			get_node("ConfirmationDialog").visible = true
		else:
			if not issue_found:
				#print(function_edit.selected)
				#print("asdbabd " + str(DataManager.UserFunction.EDITOR))
				var tmp_function: int = -1
				match function_edit.get_item_id(function_edit.selected):
					0: # Customer
						tmp_function = DataManager.UserFunction.CUSTOMER
					1: # Editor
						tmp_function = DataManager.UserFunction.EDITOR
					_: # Other
						PrintUtility.print_error("Unknown function type in user_manager._on_save_button_pressed()")
				main_scene.users.add_user(tmp_function, name_edit.text, phone_edit.text, email_edit.text)
				is_new_user = false
	
	if not issue_found:
		match function_edit.get_item_id(function_edit.selected):
			0: # Customer
				main_scene.users.change_customer(name_edit.text, phone_edit.text, email_edit.text)
			1: # Editor
				main_scene.users.change_editor(name_edit.text, phone_edit.text, email_edit.text)
			_: # Other
				PrintUtility.print_error("Unknown function type in user_manager._on_save_button_pressed()")
		#main_scene.users.change_editor(name_edit.text, phone_edit.text, email_edit.text)
		main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
		modified_user = -1
		build_users()
		panel.visible = false
		users_changed.emit()

func update_modification_dialog() -> void:
	get_node("ConfirmationDialog/VBoxContainer/Label").text = "L'utilisateur \"" + name_edit.text + "\" est déjà présent. Les modifications suivantes seront apportées :"
	get_node("ConfirmationDialog/VBoxContainer/Label2").text = ""
	var current_editor = main_scene.users.get_editor_from_name(name_edit.text)
	
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
	main_scene.users.change_editor(name_edit.text, phone_edit.text, email_edit.text)
	main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
	modified_user = -1
	build_users()
	panel.visible = false

func _on_confirmation_dialog_canceled() -> void:
	pass # Replace with function body.
