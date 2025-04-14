extends Node

enum UserFunction {
	UNKNOWN,
	EDITOR,
	CUSTOMER
}

enum SortType {
	NAME,
	PHONE,
	EMAIL,
	FUNCTION
}

enum ProductionType {
	EXTERNAL,
	INTERNAL
}

static func user_function_plain_text(user_function: UserFunction) -> String:
	var function: String = ""
	match user_function:
		UserFunction.UNKNOWN:
			function = "???"
		UserFunction.EDITOR:
			function = "Monteur"
		UserFunction.CUSTOMER:
			function = "Client"
	return function

func check_at_least_one_alphanum(text: String) -> bool:
	var result: bool = false
	for i in range(text.length()):
		if is_alphanumerical(text.unicode_at(i), false):
			result = true
	return result

func check_starts_with_alphanum(text: String) -> bool:
	var result: bool = false
	if is_alphanumerical(text.unicode_at(0), false):
		result = true
	return result

func check_doesnt_end_space_dot(text: String) -> bool:
	var result: bool = false
	if text.unicode_at(text.length()-1) != 32 and text.unicode_at(text.length()-1) != 46:
		result = true
	return result

func check_contains_only_allowed_chars(text: String) -> bool:
	var result: bool = true
	for i in range(text.length()):
		match text.unicode_at(i):
			# < > : " / \ | ? *
			60, 62, 58, 34, 47, 92, 124, 63, 42:
				result = false
	return result

func is_string_windows_ok(text: String) -> bool:
	var is_ok: bool = false
	var contains_at_least_1_alphanum: bool = false
	var starts_with_alphanum: bool = false
	var doesnt_end_with_space_dot: bool = false
	var contains_only_allowed_chars: bool = false
	
	if text != "":
		contains_at_least_1_alphanum = check_at_least_one_alphanum(text)
		starts_with_alphanum = check_starts_with_alphanum(text)
		doesnt_end_with_space_dot = check_doesnt_end_space_dot(text)
		contains_only_allowed_chars = check_contains_only_allowed_chars(text)
		is_ok = contains_at_least_1_alphanum and starts_with_alphanum and doesnt_end_with_space_dot and contains_only_allowed_chars
	else:
		is_ok = true
	
	return is_ok

func is_alphanumerical(chara: int, is_strict: bool) -> bool:
	var result: bool = false
	
	# Digits
	if chara >= 48 and chara <= 57:
		result = true
	# A-Z
	elif chara >= 65 and chara <= 90:
		result = true
	# a-z
	elif chara >= 97 and chara <= 122:
		result = true
	
	# Letters with accents
	else:
		if not is_strict:
			if chara == 158 or chara == 159:
				result = true
			elif chara >= 192 and chara <= 255:
				result = true
	
	return result

func daycount_int_to_string(value: int) -> String:
	var tmp_string: String = ""
	if value < 10:
		tmp_string += "0"
	if value < 100:
		tmp_string += "0"
	tmp_string += str(value)
	return tmp_string
