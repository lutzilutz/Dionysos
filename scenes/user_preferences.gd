class_name UserPreferences extends Resource

@export var default_path: String = ""
@export var has_default_path: bool = false
@export var editors: Array = []
@export var customers: Array = []
@export var hide_logo: bool = false
@export var show_highlights: bool = true
@export var has_seen_tutorial: bool = false

@export var achievements: Array = []

func save_to_file(path:String) -> Error:
	var json_editors:Dictionary = {}
	# Build Editor resources
	for e: Editor in editors:
		var json_infos: Dictionary = {
			"phone": e.phone,
			"email": e.email
		}
		json_editors[e.name] = json_infos
	# Build main resources
	var json = {
		"version": ProjectSettings.get_setting("application/config/version"),
		"preferences": {
			"default_path": default_path,
			"has_default_path": has_default_path,
			"editors": json_editors,
			"customers": customers,
			"hide_logo": hide_logo,
			"show_highlights": show_highlights,
			"has_seen_tutorial": has_seen_tutorial
			},
		"achievements": []
	}
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(json, "\t"))
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
			"version": ProjectSettings.get_setting("application/config/version"),
			"preferences": {
				"default_path": "",
				"has_default_path": false,
				"editors": {},
				"customers": [],
				"hide_logo": false,
				"show_highlights": true,
				"has_seen_tutorial": false
				},
			"achievements": []
		}
		if new_file:
			new_file.store_string(JSON.stringify(new_json, "\t"))
			new_file.flush()
			PrintUtility.print_info("Successful creation of user_preferences.json")
		else:
			PrintUtility.print_error("Can't write a new file user_preferences.json")
			PrintUtility.print_error(str(FileAccess.get_open_error()))
	else:
		PrintUtility.print_info("user_preferences.json found")
	
	PrintUtility.print_info("Loading user_preferences.json ...")
	var file = FileAccess.get_file_as_string(path)
	var json = JSON.parse_string(file) as Dictionary
	var res = UserPreferences.new()
	var json_pref = json.get("preferences", {})
	res.default_path = json_pref.get("default_path", "")
	res.has_default_path = json_pref.get("has_default_path", false)
	#res.editors = json_pref.get("editors", {})
	var tmp_editors = json_pref.get("editors", {})
	if tmp_editors != null :
		for e_name in tmp_editors.keys():
			var tmp_editor: Editor = Editor.new()
			tmp_editor.name = e_name
			tmp_editor.phone = tmp_editors[e_name].get("phone", "")
			tmp_editor.email = tmp_editors[e_name].get("email", "")
			res.editors.append(tmp_editor)
		#print("Found editors container ", json_pref.get("editors", {}).size())
	res.customers = json_pref.get("customers", [])
	res.hide_logo = json_pref.get("hide_logo", false)
	res.show_highlights = json_pref.get("show_highlights", true)
	res.has_seen_tutorial = json_pref.get("has_seen_tutorial", false)
	if json.get("version", "") != ProjectSettings.get_setting("application/config/version"):
		PrintUtility.print_info("Current preferences are version " + json.get("version", "") + " but Dionysos is version " + ProjectSettings.get_setting("application/config/version"))
		PrintUtility.print_TODO("Manage upgrade of preferences.json")
	return res

func reset_user_preferences(path: String) -> void:
	default_path = ""
	has_default_path = false
	customers = []
	hide_logo = false
	show_highlights = true
	has_seen_tutorial = false
	save_to_file(path)

func editor_exists(new_name: String) -> bool:
	var editor_found: bool = false
	for e in editors:
		if e.name.capitalize() == new_name.capitalize():
			editor_found = true
			break
	return editor_found

func add_editor(name: String, phone: String, email: String) -> void:
	var editor: Editor = Editor.new()
	editor.name = name
	editor.phone = phone
	editor.email = email
	editors.append(editor)

func change_editor(name: String, phone: String, email: String) -> void:
	var new_editor: Editor = Editor.new()
	new_editor.name = name
	new_editor.phone = phone
	new_editor.email = email
	for e in editors:
		if e.name.capitalize() == name.capitalize():
			if new_editor.name != e.name or new_editor.phone != e.phone or new_editor.email != e.email:
				PrintUtility.print_info("User changing editor infos, from, to :")
				PrintUtility.print_info(e.name + " - " + e.phone + " - " + e.email)
				PrintUtility.print_info(name + " - " + phone + " - " + email)
			e.name = name
			e.phone = phone
			e.email = email
