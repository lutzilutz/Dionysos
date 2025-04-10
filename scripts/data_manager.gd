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

#static func is_valid_name(text: String) -> bool:
	#var result: bool = false
	#
	##if text.containsn()
	#
	#return result

static func is_alphanumerical(chara: int, is_strict: bool) -> bool:
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
