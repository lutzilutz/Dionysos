extends Control

signal users_changed

var main_scene
var modified_user: User = null
var is_new_user: bool = true

@onready var filters_container = get_node("VBoxContainer/FiltersHBox")
@onready var filters_option = get_node("VBoxContainer/FiltersHBox/FilterFunctionOption")
@onready var count_label = get_node("VBoxContainer/FiltersHBox/CountLabel")
@onready var users_header = get_node("VBoxContainer/UserItemHeader")
@onready var users_container = get_node("VBoxContainer/UsersScroll/VBoxContainer/UsersVBox")
@onready var panel = get_node("VBoxContainer/Panel")
@onready var modify_panel = panel.get_node("MarginContainer/ModifyPanel")
@onready var name_edit = modify_panel.get_node("NameEdit")
@onready var phone_edit = modify_panel.get_node("PhoneEdit")
@onready var email_edit = modify_panel.get_node("EmailEdit")
@onready var function_edit = modify_panel.get_node("FunctionOption")
@onready var save_button = modify_panel.get_node("SaveButton")
@onready var cancel_button = modify_panel.get_node("CancelButton")

func _ready() -> void:
	users_header.sort_by_name.connect(_on_header_sort_by_name)
	users_header.sort_by_phone.connect(_on_header_sort_by_phone)
	users_header.sort_by_email.connect(_on_header_sort_by_email)
	users_header.sort_by_function.connect(_on_header_sort_by_function)
	function_edit.selected = -1

func _on_header_sort_by_name(ascending: bool) -> void:
	PrintUtility.print_signal("Sort by name ascending " + str(ascending))
	build_users()

func _on_header_sort_by_phone(ascending: bool) -> void:
	PrintUtility.print_signal("Sort by phone ascending " + str(ascending))
	build_users()

func _on_header_sort_by_email(ascending: bool) -> void:
	PrintUtility.print_signal("Sort by email ascending " + str(ascending))
	build_users()

func _on_header_sort_by_function(ascending: bool) -> void:
	PrintUtility.print_signal("Sort by function ascending " + str(ascending))
	build_users()

func update_controls() -> void:
	var can_save: bool = name_edit.text != "" and function_edit.selected != -1
	save_button.disabled = not can_save

func update_labels() -> void:
	var count_visible: int = 0
	for ui in users_container.get_children():
		if ui.visible: count_visible += 1
	count_label.text = "Utilisateurs affichés / total : " + str(count_visible) + "/" + str(users_container.get_child_count())

func build_users() -> void:
	if main_scene.users.all_users.size() == 0:
		PrintUtility.print_info("No user")
	
	for u in users_container.get_children():
		if u is UserItem:
			u.queue_free()
			await u.tree_exited
		else:
			PrintUtility.print_error("Unknown item in user manager spreadsheet : " + u.name)
	
	var users: Array = main_scene.users.all_users.duplicate(true)
	users.sort_custom(sort_users)
	#var is_even: bool = false
	for u in users:
		var user_item: UserItem = UserItem.user_item_scene.instantiate()
		user_item.set_user(u)
		user_item.ask_edition.connect(_on_user_item_ask_edition)
		user_item.ask_deletion.connect(_on_user_item_ask_deletion)
		initialize_visibility(user_item)
		users_container.add_child(user_item)
	update_even()
	update_labels()

func initialize_visibility(user_item: UserItem) -> void:
	match filters_option.get_item_id(filters_option.selected):
		DataManager.UserFunction.UNKNOWN:
			pass
		DataManager.UserFunction.CUSTOMER:
			if user_item.user.function != DataManager.UserFunction.CUSTOMER:
				user_item.visible = false
		DataManager.UserFunction.EDITOR:
			if user_item.user.function != DataManager.UserFunction.EDITOR:
				user_item.visible = false
		_:
			pass

func sort_users(a, b) -> bool:
	var a_is_greater: bool = false
	match users_header.currently_sorted_by:
		DataManager.SortType.NAME:
			if a.name.capitalize() > b.name.capitalize():
				a_is_greater = true
			elif a.name.capitalize() < b.name.capitalize():
				a_is_greater = false
			else:
				if a.function > b.function:
					a_is_greater = true
			if users_header.name_ascending: a_is_greater = not a_is_greater
		DataManager.SortType.PHONE:
			if a.phone > b.phone:
				a_is_greater = true
			elif a.phone < b.phone:
				a_is_greater = false
			else:
				if a.name.capitalize() > b.name.capitalize():
					a_is_greater = true
			if users_header.phone_ascending: a_is_greater = not a_is_greater
		DataManager.SortType.EMAIL:
			if a.email > b.email:
				a_is_greater = true
			elif a.email < b.email:
				a_is_greater = false
			else:
				if a.name.capitalize() > b.name.capitalize():
					a_is_greater = true
			if users_header.email_ascending: a_is_greater = not a_is_greater
		DataManager.SortType.FUNCTION:
			if a.function > b.function:
				a_is_greater = true
			elif a.function < b.function:
				a_is_greater = false
			else:
				if a.name.capitalize() > b.name.capitalize():
					a_is_greater = true
			if users_header.function_ascending: a_is_greater = not a_is_greater
		_:
			PrintUtility.print_error("Unknown sort type " + str(users_header.currently_sorted_by) + " in user_manager.sort_users(a, b)")
	return a_is_greater

func _on_user_item_ask_edition(user: User) -> void:
	var current_user: User = null
	for u in users_container.get_children():
		if u.user.is_same_as(user):
			current_user = user
		else:
			u.emphasized(false)
	
	name_edit.text = current_user.name
	name_edit.editable = false
	phone_edit.text = current_user.phone
	email_edit.text = current_user.email
	match current_user.function:
		DataManager.UserFunction.CUSTOMER:
			function_edit.selected = 0
		DataManager.UserFunction.EDITOR:
			function_edit.selected = 1
		_:
			PrintUtility.print_error("Unknown function type in user_manager._on_user_item_ask_edition()")
	function_edit.disabled = true
	update_controls()
	panel.visible = true

func _on_user_item_ask_deletion(user: User) -> void:
	modified_user = user
	get_node("AcceptDialog/Label").text = "L'utilisateur \"" + modified_user.name + "\" sera définitivement supprimé, non-reversible.\nVoulez-vous le supprimer ?"
	get_node("AcceptDialog").visible = true

func _on_accept_dialog_confirmed() -> void:
	main_scene.users.remove_user(modified_user)
	main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
	build_users()
	users_changed.emit()
	modified_user = null

func _on_accept_dialog_canceled() -> void:
	pass # Replace with function body.

func _on_save_button_pressed() -> void:
	var issue_found: bool = false
	
	if not is_new_user:
		PrintUtility.print_TODO("Try editing existing user")
	else:
		if (main_scene.users.editor_exists(name_edit.text) and function_edit.selected == 1) or (main_scene.users.customer_exists(name_edit.text) and function_edit.selected == 0):
			issue_found = true
			update_modification_dialog()
			get_node("ConfirmationDialog").visible = true
		else:
			if not issue_found:
				var tmp_function: int = -1
				match function_edit.get_item_id(function_edit.selected):
					0: # Customer
						tmp_function = DataManager.UserFunction.CUSTOMER
					1: # Editor
						tmp_function = DataManager.UserFunction.EDITOR
					_: # Other
						PrintUtility.print_error("Unknown function type in user_manager._on_save_button_pressed() : " + str(function_edit.get_item_id(function_edit.selected)))
				main_scene.users.add_user(tmp_function, name_edit.text, phone_edit.text, email_edit.text)
	
	if not issue_found:
		var new_user: User = User.new()
		new_user.name = name_edit.text
		match function_edit.selected:
			0:
				new_user.function = DataManager.UserFunction.CUSTOMER
			1:
				new_user.function = DataManager.UserFunction.EDITOR
			_:
				PrintUtility.print_error("Unknown function type in user_manager._on_save_button_pressed() : " + str(function_edit.selected))
		new_user.phone = phone_edit.text
		new_user.email = email_edit.text
		match function_edit.get_item_id(function_edit.selected):
			0: # Customer
				PrintUtility.print_info("Changing customer")
				main_scene.users.change_user(new_user)
				main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
			1: # Editor
				PrintUtility.print_info("Changing editor")
				main_scene.users.change_user(new_user)
				main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
			_: # Other
				PrintUtility.print_error("Unknown function type in user_manager._on_save_button_pressed() : " + str(function_edit.get_item_id(function_edit.selected)))
		modified_user = null
		build_users()
		panel.visible = false
		users_changed.emit()
		filters_option.selected = 0

func update_modification_dialog() -> void:
	var current_user: User = null
	
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

func reset_all_emphasis() -> void:
	for ui in users_container.get_children():
		ui.emphasized(false)

func _on_cancel_button_pressed() -> void:
	cancel_selection()

func cancel_selection() -> void:
	reset_all_emphasis()
	modified_user = null
	panel.visible = false

func _on_new_button_pressed() -> void:
	name_edit.editable = true
	name_edit.text = ""
	phone_edit.text = ""
	email_edit.text = ""
	function_edit.selected = -1
	function_edit.disabled = false
	panel.visible = true
	update_controls()
	modified_user = User.new()

func _on_confirmation_dialog_confirmed() -> void:
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

func _on_name_edit_text_changed(_new_text: String) -> void:
	update_controls()

func _on_function_option_item_selected(_index: int) -> void:
	update_controls()

func filter_items(show_editors: bool, show_customers: bool) -> void:
	cancel_selection()
	for ui in users_container.get_children():
		if ui.user.function == DataManager.UserFunction.EDITOR:
			ui.visible = show_editors
		elif ui.user.function == DataManager.UserFunction.CUSTOMER:
			ui.visible = show_customers
		else:
			PrintUtility.print_error("UserItem doesn't have a function ! In user_manager.filter_items()")

func update_even() -> void:
	var temp_even: bool = false
	for ui in users_container.get_children():
		if ui.visible:
			ui.set_is_even(temp_even)
			temp_even = not temp_even

func _on_filter_function_option_item_selected(index: int) -> void:
	match filters_option.get_item_id(index):
		DataManager.UserFunction.UNKNOWN:
			filter_items(true, true)
		DataManager.UserFunction.CUSTOMER:
			filter_items(false, true)
		DataManager.UserFunction.EDITOR:
			filter_items(true, false)
		_:
			pass
	update_even()
	update_labels()

func _on_all_delete_button_pressed() -> void:
	PrintUtility.print_info("User asked to delete all users")
	get_node("AllDeleteDialog").visible = true
	get_node("AllDeleteDialog/Label").text = "Tous les utilisateurs (" + str(main_scene.users.all_users.size()) + ") seront définitivement supprimés, non-reversible.\nVoulez-vous les supprimer ?"

func _on_all_delete_dialog_canceled() -> void:
	PrintUtility.print_info("User canceled deletetion of all users")

func _on_all_delete_dialog_confirmed() -> void:
	PrintUtility.print_info("User confirmed deletetion of all users")
	PrintUtility.print_info("Delete all users")
	main_scene.users.purge_editors()
	main_scene.users.purge_customers()
	main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
	build_users()
