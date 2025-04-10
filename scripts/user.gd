class_name User extends Resource

@export var name: String = ""
@export var phone: String = ""
@export var email: String = ""
@export var function: DataManager.UserFunction = DataManager.UserFunction.UNKNOWN

func is_same_as(new_user: User) -> bool:
	var found_similar: bool = false
	if name.capitalize() == new_user.name.capitalize() and function == new_user.function:
		found_similar = true
	return found_similar
