extends Control

signal users_changed

var main_scene
var modified_user: User = null
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
	
	#for i in range(users.size()):
		#var tmp_user: UserItem = UserItem.new_user(
			#i,
			#users[i].function,
			#users[i].name,
			#users[i].phone,
			#users[i].email)
		##tmp_user.change_user(i, DataManager.UserFunction.EDITOR, main_scene.user_preferences.editors[i].name, main_scene.user_preferences.editors[i].phone, main_scene.user_preferences.editors[i].email)
		#tmp_user.ask_edition.connect(_on_user_item_ask_edition)
		#tmp_user.ask_deletion.connect(_on_user_item_ask_deletion)
		#users_container.add_child(tmp_user)
	
	for u in users:
		#print(u.name)
		var user_item: UserItem = UserItem.user_item_scene.instantiate()
		user_item.set_user(u)
		user_item.ask_edition.connect(_on_user_item_ask_edition)
		user_item.ask_deletion.connect(_on_user_item_ask_deletion)
		users_container.add_child(user_item)
	
	#print("users_container has children = " + str(users_container.get_child_count()))
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

func _on_user_item_ask_edition(user: User) -> void:
	var current_user: User = null
	for u in users_container.get_children():
		if u.user.is_same_as(user):
			current_user = user
	
	#reset_emphasis(index)
	#modified_user = index
	name_edit.text = current_user.name
	name_edit.editable = false
	phone_edit.text = current_user.phone
	email_edit.text = current_user.email
	panel.visible = true

func _on_user_item_ask_deletion(user: User) -> void:
	modified_user = user
	get_node("AcceptDialog/Label").text = "L'utilisateur \"" + modified_user.name + "\" sera définitivement supprimé, non-reversible.\nVoulez-vous le supprimer ?"
	get_node("AcceptDialog").visible = true

#func _on_user_item_ask_edition(index: int) -> void:
	#reset_emphasis(index)
	#modified_user = index
	#name_edit.text = main_scene.users.editors[modified_user].name
	#name_edit.editable = false
	#phone_edit.text = main_scene.users.editors[modified_user].phone
	#email_edit.text = main_scene.users.editors[modified_user].email
	#panel.visible = true
#
#func _on_user_item_ask_deletion(index: int) -> void:
	#modified_user = index
	#get_node("AcceptDialog/Label").text = "L'utilisateur \"" + main_scene.users.editors[modified_user].name + "\" sera définitivement supprimé, non-reversible.\nVoulez-vous le supprimer ?"
	#get_node("AcceptDialog").visible = true

func _on_accept_dialog_confirmed() -> void:
	#main_scene.users.remove_editor(modified_user)
	main_scene.users.remove_user(modified_user)
	main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
	build_users()
	users_changed.emit()
	modified_user = null

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
		if (main_scene.users.editor_exists(name_edit.text) and function_edit.selected == 1) or (main_scene.users.customer_exists(name_edit.text) and function_edit.selected == 0):
			issue_found = true
			#print(main_scene.users.)
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
						PrintUtility.print_error("Unknown function type in user_manager._on_save_button_pressed() : " + str(function_edit.get_item_id(function_edit.selected)))
				main_scene.users.add_user(tmp_function, name_edit.text, phone_edit.text, email_edit.text)
				is_new_user = false
	
	if not issue_found:
		var new_user: User = User.new()
		new_user.name = name_edit.text
		new_user.function = function_edit.get_item_id(function_edit.selected)
		new_user.phone = phone_edit.text
		new_user.email = email_edit.text
		match function_edit.get_item_id(function_edit.selected):
			0: # Customer or editor
				main_scene.users.change_user(new_user)
				main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
			1: # Customer or editor
				main_scene.users.change_user(new_user)
				main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
			_: # Other
				PrintUtility.print_error("Unknown function type in user_manager._on_save_button_pressed() : " + str(function_edit.get_item_id(function_edit.selected)))
		modified_user = null
		build_users()
		panel.visible = false
		users_changed.emit()

func update_modification_dialog() -> void:
	#var current_user = main_scene.users.get_user_from_name(name_edit.text)
	var current_user: User = null
	
	#main_scene.users.get_user_from_name(1+function_edit.get_item_id(function_edit.selected), name_edit.text)
	
	match function_edit.get_item_id(function_edit.selected):
		0: # Customers
			current_user = main_scene.users.get_user_from_name(DataManager.UserFunction.CUSTOMER, name_edit.text)
		1: # Editors
			current_user = main_scene.users.get_user_from_name(DataManager.UserFunction.EDITOR, name_edit.text)
		_:
			PrintUtility.print_error("Unknown function type in user_manager.update_modification_dialog()")
	
	get_node("ConfirmationDialog/VBoxContainer/Label").text = "L'utilisateur \"" + name_edit.text + "\" est déjà présent. Les modifications suivantes seront apportées :"
	get_node("ConfirmationDialog/VBoxContainer/Label2").text = ""
	
	if name_edit.text != current_user.name:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "Nom : " + current_user.name + " -> " + name_edit.text + "\n"
	else:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "\n"
	
	if phone_edit.text != current_user.phone:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "Téléphone : " + current_user.phone + " -> " + phone_edit.text + "\n"
	else:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "\n"
	
	if email_edit.text != current_user.email:
		get_node("ConfirmationDialog/VBoxContainer/Label2").text += "E-mail : " + current_user.email + " -> " + email_edit.text

#func update_modification_dialog() -> void:
	#var current_user = main_scene.users.get_user_from_name(name_edit.text)
	#
	#get_node("ConfirmationDialog/VBoxContainer/Label").text = "L'utilisateur \"" + name_edit.text + "\" est déjà présent. Les modifications suivantes seront apportées :"
	#get_node("ConfirmationDialog/VBoxContainer/Label2").text = ""
	#
	#if name_edit.text != current_user.name:
		#get_node("ConfirmationDialog/VBoxContainer/Label2").text += "Nom : " + current_user.name + " -> " + name_edit.text + "\n"
	#else:
		#get_node("ConfirmationDialog/VBoxContainer/Label2").text += "\n"
	#
	#if phone_edit.text != current_user.phone:
		#get_node("ConfirmationDialog/VBoxContainer/Label2").text += "Téléphone : " + current_user.phone + " -> " + phone_edit.text + "\n"
	#else:
		#get_node("ConfirmationDialog/VBoxContainer/Label2").text += "\n"
	#
	#if email_edit.text != current_user.email:
		#get_node("ConfirmationDialog/VBoxContainer/Label2").text += "E-mail : " + current_user.email + " -> " + email_edit.text

func _on_cancel_button_pressed() -> void:
	modified_user = null
	panel.visible = false
	is_new_user = false

func _on_new_button_pressed() -> void:
	is_new_user = true
	name_edit.editable = true
	name_edit.text = ""
	phone_edit.text = ""
	email_edit.text = ""
	panel.visible = true
	modified_user = User.new()

func _on_confirmation_dialog_confirmed() -> void:
	#main_scene.users.change_editor(name_edit.text, phone_edit.text, email_edit.text)
	var new_user: User = User.new()
	new_user.name = name_edit.text
	match function_edit.get_item_id(function_edit.selected):
		0: # Customers
			new_user.function = DataManager.UserFunction.CUSTOMER
		1: # Editors
			new_user.function = DataManager.UserFunction.EDITOR
		_:
			PrintUtility.print_error("Unknown function type in user_manager._on_confirmation_dialog_confirmed()")
	new_user.phone = phone_edit.text
	new_user.email = email_edit.text
	main_scene.users.change_user(new_user)
	main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
	modified_user = null
	build_users()
	panel.visible = false

func _on_confirmation_dialog_canceled() -> void:
	pass # Replace with function body.
