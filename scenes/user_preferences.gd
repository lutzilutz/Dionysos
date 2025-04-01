class_name UserPreferences extends Resource

const DEFAULT_PATH: String = ""
const HAS_DEFAULT_PATH: bool = false
const EDITORS_INCODE: Array = []
const EDITORS_INFILE: Dictionary = {}
const CUSTOMERS: Array = []
const HIDE_LOGO: bool = false
const SHOW_HIGHLIGHTS: bool = false
const HAS_SEEN_TUTORIAL: bool = false

const LUTZ_NAME: String = "Lutzi Lutz"
const LUTZ_PHONE: String = "079 152 04 95"
const LUTZ_EMAIL: String = "lutz@drykats.ch"
const YANN_NAME: String = "Yann Matousek"
const YANN_PHONE: String = "076 370 23 08"
const YANN_EMAIL: String = "yann.matousek@drykats.ch"
const KAREL_NAME: String = "Karel Matousek"
const KAREL_PHONE: String = "076 370 22 69"
const KAREL_EMAIL: String = "karel.matousek@drykats.ch"

@export var default_path: String = DEFAULT_PATH
@export var has_default_path: bool = HAS_DEFAULT_PATH
@export var editors: Array = []
@export var customers: Array = []
@export var hide_logo: bool = HIDE_LOGO
@export var show_highlights: bool = SHOW_HIGHLIGHTS
@export var has_seen_tutorial: bool = HAS_SEEN_TUTORIAL

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

func purge_editors() -> void:
	editors.clear()
	add_editor(KAREL_NAME, KAREL_PHONE, KAREL_EMAIL)
	add_editor(LUTZ_NAME, LUTZ_PHONE, LUTZ_EMAIL)
	add_editor(YANN_NAME, YANN_PHONE, YANN_EMAIL)

static func generate_drykats_team() -> Dictionary:
	var d: Dictionary
	d[LUTZ_NAME] = {
		"phone": LUTZ_PHONE,
		"email": LUTZ_EMAIL
	}
	d[YANN_NAME] = {
		"phone": YANN_PHONE,
		"email": YANN_EMAIL
	}
	d[KAREL_NAME] = {
		"phone": KAREL_PHONE,
		"email": KAREL_EMAIL
	}
	return d

static func load_from_file(path: String) -> UserPreferences:
	# Check if a user preferences file already exists (not first time)
	# If not, creates a default JSON file to be used
	if not FileAccess.file_exists(path):
		PrintUtility.print_info("No user_preferences.json found")
		var new_file = FileAccess.open(path, FileAccess.WRITE)
		var new_json = {
			"version": ProjectSettings.get_setting("application/config/version"),
			"preferences": {
				"default_path": DEFAULT_PATH,
				"has_default_path": HAS_DEFAULT_PATH,
				"editors": generate_drykats_team(),
				"customers": CUSTOMERS,
				"hide_logo": HIDE_LOGO,
				"show_highlights": SHOW_HIGHLIGHTS,
				"has_seen_tutorial": HAS_SEEN_TUTORIAL
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
	res.default_path = json_pref.get("default_path", DEFAULT_PATH)
	res.has_default_path = json_pref.get("has_default_path", HAS_DEFAULT_PATH)
	var tmp_editors = json_pref.get("editors", EDITORS_INCODE)
	if tmp_editors != null :
		for e_name in tmp_editors.keys():
			var tmp_editor: Editor = Editor.new()
			tmp_editor.name = e_name
			tmp_editor.phone = tmp_editors[e_name].get("phone", "")
			tmp_editor.email = tmp_editors[e_name].get("email", "")
			res.editors.append(tmp_editor)
	res.customers = json_pref.get("customers", CUSTOMERS)
	res.hide_logo = json_pref.get("hide_logo", HIDE_LOGO)
	res.show_highlights = json_pref.get("show_highlights", SHOW_HIGHLIGHTS)
	res.has_seen_tutorial = json_pref.get("has_seen_tutorial", HAS_SEEN_TUTORIAL)
	if json.get("version", "") != ProjectSettings.get_setting("application/config/version"):
		PrintUtility.print_info("Current preferences are version " + json.get("version", "") + " but Dionysos is version " + ProjectSettings.get_setting("application/config/version"))
		PrintUtility.print_TODO("Manage upgrade of preferences.json")
	return res

func reset_user_preferences(path: String) -> void:
	default_path = DEFAULT_PATH
	has_default_path = HAS_DEFAULT_PATH
	hide_logo = HIDE_LOGO
	show_highlights = SHOW_HIGHLIGHTS
	has_seen_tutorial = HAS_SEEN_TUTORIAL
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
	if editors.is_read_only():
		PrintUtility.print_error("user_preferences.editors is in read-only state")
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
