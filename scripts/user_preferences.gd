class_name UserPreferences extends Resource

const DEFAULT_PATH: String = ""
const HAS_DEFAULT_PATH: bool = false
const FOLDER_FOLLOW_CONVENTIONS: bool = true
const HIDE_LOGO: bool = false
const SHOW_HIGHLIGHTS: bool = false
const SHOW_IDS: bool = false
const HAS_SEEN_TUTORIAL: bool = false

@export var default_path: String = DEFAULT_PATH
@export var has_default_path: bool = HAS_DEFAULT_PATH
@export var folder_follow_conventions: bool = FOLDER_FOLLOW_CONVENTIONS
@export var hide_logo: bool = HIDE_LOGO
@export var show_highlights: bool = SHOW_HIGHLIGHTS
@export var show_ids: bool = SHOW_IDS
@export var has_seen_tutorial: bool = HAS_SEEN_TUTORIAL
@export var last_user_import_path: String = DEFAULT_PATH
@export var last_edit_manager_path: String = DEFAULT_PATH

@export var achievements: Array = []

func save_to_file(path:String) -> Error:
	# Build main resources
	var json = {
		"version": ProjectSettings.get_setting("application/config/version"),
		"preferences": {
			"default_path": default_path,
			"has_default_path": has_default_path,
			"folder_follow_conventions": folder_follow_conventions,
			"hide_logo": hide_logo,
			"show_highlights": show_highlights,
			"show_ids": show_ids,
			"has_seen_tutorial": has_seen_tutorial,
			"last_user_import_path": last_user_import_path,
			"last_edit_manager_path": last_edit_manager_path
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
				"default_path": DEFAULT_PATH,
				"has_default_path": HAS_DEFAULT_PATH,
				"folder_follow_conventions": FOLDER_FOLLOW_CONVENTIONS,
				"hide_logo": HIDE_LOGO,
				"show_highlights": SHOW_HIGHLIGHTS,
				"show_ids": SHOW_IDS,
				"has_seen_tutorial": HAS_SEEN_TUTORIAL,
				"last_user_import_path": DEFAULT_PATH,
				"last_edit_manager_path": DEFAULT_PATH
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
	res.folder_follow_conventions = json_pref.get("folder_follow_conventions", FOLDER_FOLLOW_CONVENTIONS)
	res.hide_logo = json_pref.get("hide_logo", HIDE_LOGO)
	res.show_highlights = json_pref.get("show_highlights", SHOW_HIGHLIGHTS)
	res.show_ids = json_pref.get("show_ids", SHOW_IDS)
	res.has_seen_tutorial = json_pref.get("has_seen_tutorial", HAS_SEEN_TUTORIAL)
	res.last_user_import_path = json_pref.get("last_user_import_path", DEFAULT_PATH)
	res.last_edit_manager_path = json_pref.get("last_edit_manager_path", DEFAULT_PATH)
	if json.get("version", "") != ProjectSettings.get_setting("application/config/version"):
		PrintUtility.print_info("Current preferences are version " + json.get("version", "") + " but Dionysos is version " + ProjectSettings.get_setting("application/config/version"))
		PrintUtility.print_TODO("Manage upgrade of preferences.json")
	return res

func reset_user_preferences(path: String) -> void:
	default_path = DEFAULT_PATH
	has_default_path = HAS_DEFAULT_PATH
	folder_follow_conventions = FOLDER_FOLLOW_CONVENTIONS
	hide_logo = HIDE_LOGO
	show_highlights = SHOW_HIGHLIGHTS
	show_ids = SHOW_IDS
	has_seen_tutorial = HAS_SEEN_TUTORIAL
	last_user_import_path = DEFAULT_PATH
	last_edit_manager_path = DEFAULT_PATH
	save_to_file(path)
