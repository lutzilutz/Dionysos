extends Control

signal sort_by_name(ascending)
signal sort_by_phone(ascending)
signal sort_by_email(ascending)
signal sort_by_function(ascending)

var currently_sorted_by: int = 0
var name_ascending: bool = true
var phone_ascending: bool = true
var email_ascending: bool = true
var function_ascending: bool = true

func update_flags(type: DataManager.SortType) -> void:
	# type is the column that doesn't need update
	match type:
		DataManager.SortType.NAME:
			phone_ascending = true
			reset_label(DataManager.SortType.PHONE)
			email_ascending = true
			reset_label(DataManager.SortType.EMAIL)
			function_ascending = true
			reset_label(DataManager.SortType.FUNCTION)
		DataManager.SortType.PHONE:
			name_ascending = true
			reset_label(DataManager.SortType.NAME)
			email_ascending = true
			reset_label(DataManager.SortType.EMAIL)
			function_ascending = true
			reset_label(DataManager.SortType.FUNCTION)
		DataManager.SortType.EMAIL:
			name_ascending = true
			reset_label(DataManager.SortType.NAME)
			phone_ascending = true
			reset_label(DataManager.SortType.PHONE)
			function_ascending = true
			reset_label(DataManager.SortType.FUNCTION)
		DataManager.SortType.FUNCTION:
			name_ascending = true
			reset_label(DataManager.SortType.NAME)
			phone_ascending = true
			reset_label(DataManager.SortType.PHONE)
			email_ascending = true
			reset_label(DataManager.SortType.EMAIL)

func reset_label(type: DataManager.SortType) -> void:
	if type == DataManager.SortType.NAME:
		get_node("MarginContainer/UserContainer/UserNameButton/UserNameLabel").text = "Nom de l'utilisateur"
	elif type == DataManager.SortType.PHONE:
		get_node("MarginContainer/UserContainer/UserPhoneButton/UserPhoneLabel").text = "Téléphone"
	elif type == DataManager.SortType.EMAIL:
		get_node("MarginContainer/UserContainer/UserEmailButton/UserEmailLabel").text = "E-mail"
	elif type == DataManager.SortType.FUNCTION:
		get_node("MarginContainer/UserContainer/UserFunctionButton/UserFunctionLabel").text = "Fonction"

func _on_user_name_button_pressed() -> void:
	if currently_sorted_by == DataManager.SortType.NAME:
		name_ascending = not name_ascending
	else:
		update_flags(DataManager.SortType.NAME)
	
	if name_ascending:
		get_node("MarginContainer/UserContainer/UserNameButton/UserNameLabel").text = "Nom de l'utilisateur ˅"
	else:
		get_node("MarginContainer/UserContainer/UserNameButton/UserNameLabel").text = "Nom de l'utilisateur ˄"
	currently_sorted_by = DataManager.SortType.NAME
	sort_by_name.emit(name_ascending)

func _on_user_phone_button_pressed() -> void:
	if currently_sorted_by == DataManager.SortType.PHONE:
		phone_ascending = not phone_ascending
	else:
		update_flags(DataManager.SortType.PHONE)
	if phone_ascending:
		get_node("MarginContainer/UserContainer/UserPhoneButton/UserPhoneLabel").text = "Téléphone ˅"
	else:
		get_node("MarginContainer/UserContainer/UserPhoneButton/UserPhoneLabel").text = "Téléphone ˄"
	currently_sorted_by = DataManager.SortType.PHONE
	sort_by_phone.emit(phone_ascending)

func _on_user_email_button_pressed() -> void:
	if currently_sorted_by == DataManager.SortType.EMAIL:
		email_ascending = not email_ascending
	else:
		update_flags(DataManager.SortType.EMAIL)
	if email_ascending:
		get_node("MarginContainer/UserContainer/UserEmailButton/UserEmailLabel").text = "E-mail ˅"
	else:
		get_node("MarginContainer/UserContainer/UserEmailButton/UserEmailLabel").text = "E-mail ˄"
	currently_sorted_by = DataManager.SortType.EMAIL
	sort_by_email.emit(email_ascending)

func _on_user_function_button_pressed() -> void:
	if currently_sorted_by == DataManager.SortType.FUNCTION:
		function_ascending = not function_ascending
	else:
		update_flags(DataManager.SortType.FUNCTION)
	if function_ascending:
		get_node("MarginContainer/UserContainer/UserFunctionButton/UserFunctionLabel").text = "Fonction ˅"
	else:
		get_node("MarginContainer/UserContainer/UserFunctionButton/UserFunctionLabel").text = "Fonction ˄"
	currently_sorted_by = DataManager.SortType.FUNCTION
	sort_by_function.emit(function_ascending)
