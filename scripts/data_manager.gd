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
