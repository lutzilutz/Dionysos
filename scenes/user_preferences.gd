class_name UserPreferences extends Resource

@export var default_path: String = ""
@export var has_default_path: bool = false
@export var customers: Array = []

func save_to_file(path:String) -> Error:
	var json = {
		"default_path": default_path,
		"has_default_path": has_default_path,
		"customers": customers
	}
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(json))
		file.flush()
		return OK
	else:
		return ERR_FILE_CANT_WRITE

static func load_from_file(path: String) -> UserPreferences:
	
	# Check if a user preferences file already exists (not first time)
	# If not, creates a default JSON file to be used
	if not FileAccess.file_exists(path):
		PrintUtility.print_info("No user_preferences.json found")
		var new_file = FileAccess.open(path, FileAccess.WRITE)
		var new_json = {
			"default_path": "",
			"has_default_path": false,
			"customers": []
		}
		if new_file:
			new_file.store_string(JSON.stringify(new_json))
			new_file.flush()
			PrintUtility.print_info("Successful creation of user_preferences.json")
		else:
			PrintUtility.print_error("Can't write a new file user_preferences.json")
			PrintUtility.print_error(str(new_file.get_open_error()))
	else:
		PrintUtility.print_info("user_preferences.json found")
	
	PrintUtility.print_info("Loading user_preferences.json ...")
	var file = FileAccess.get_file_as_string(path)
	var json = JSON.parse_string(file) as Dictionary
	var res = UserPreferences.new()
	res.default_path = json.get("default_path", "")
	res.has_default_path = json.get("has_default_path", false)
	res.customers = json.get("customers", [])
	
	return res

func reset_user_preferences(path: String) -> void:
	default_path = ""
	has_default_path = false
	customers = []
	save_to_file(path)
