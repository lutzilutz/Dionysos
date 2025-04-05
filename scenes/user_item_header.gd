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
			email_ascending = true
			function_ascending = true
		DataManager.SortType.PHONE:
			name_ascending = true
			email_ascending = true
			function_ascending = true
		DataManager.SortType.EMAIL:
			name_ascending = true
			phone_ascending = true
			function_ascending = true
		DataManager.SortType.FUNCTION:
			name_ascending = true
			phone_ascending = true
			function_ascending = true

func _on_user_name_button_pressed() -> void:
	if currently_sorted_by == DataManager.SortType.NAME:
		name_ascending = not name_ascending
	else:
		update_flags(DataManager.SortType.NAME)
	currently_sorted_by = DataManager.SortType.NAME
	sort_by_name.emit(name_ascending)

func _on_user_phone_button_pressed() -> void:
	if currently_sorted_by == DataManager.SortType.PHONE:
		phone_ascending = not phone_ascending
	else:
		update_flags(DataManager.SortType.PHONE)
	currently_sorted_by = DataManager.SortType.PHONE
	sort_by_phone.emit(phone_ascending)

func _on_user_email_button_pressed() -> void:
	if currently_sorted_by == DataManager.SortType.EMAIL:
		email_ascending = not email_ascending
	else:
		update_flags(DataManager.SortType.EMAIL)
	currently_sorted_by = DataManager.SortType.EMAIL
	sort_by_email.emit(email_ascending)

func _on_user_function_button_pressed() -> void:
	if currently_sorted_by == DataManager.SortType.FUNCTION:
		function_ascending = not function_ascending
	else:
		update_flags(DataManager.SortType.FUNCTION)
	currently_sorted_by = DataManager.SortType.FUNCTION
	sort_by_function.emit(function_ascending)
