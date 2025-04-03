class_name UserPreferences extends Resource

const DEFAULT_PATH: String = ""
const HAS_DEFAULT_PATH: bool = false
const EDITORS_INCODE: Array = []
const EDITORS_INFILE: Dictionary = {}
const CUSTOMERS: Array = []
const HIDE_LOGO: bool = false
const SHOW_HIGHLIGHTS: bool = false
const HAS_SEEN_TUTORIAL: bool = false

const LUTZ_NAME: String = "Wfekt Wfek"
const LUTZ_PHONE: String = "180 263 15 06"
const LUTZ_EMAIL: String = "wfek@ocjvled.ns"
const YANN_NAME: String = "Jlyy Xlezfdpv"
const YANN_PHONE: String = "187 481 34 19"
const YANN_EMAIL: String = "jlyy.xlezfdpv@ocjvled.ns"
const KAREL_NAME: String = "Vlcpw Xlezfdpv"
const KAREL_PHONE: String = "187 481 33 70"
const KAREL_EMAIL: String = "vlcpw.xlezfdpv@ocjvled.ns"

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
	add_editor(decrypt_string(KAREL_NAME), decrypt_string(KAREL_PHONE), decrypt_string(KAREL_EMAIL))
	add_editor(decrypt_string(LUTZ_NAME), decrypt_string(LUTZ_PHONE), decrypt_string(LUTZ_EMAIL))
	add_editor(decrypt_string(YANN_NAME), decrypt_string(YANN_PHONE), decrypt_string(YANN_EMAIL))

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

func get_editor_from_name(name: String) -> Editor:
	var tmp_editor: Editor
	for e in editors:
		if e.name.capitalize() == name.capitalize():
			return e
	return tmp_editor

func remove_editor(index: int) -> void:
	editors.remove_at(index)

func encrypt_string(text: String) -> String:
	var new_text: String = ""
	for i in range(text.length()):
		if text.unicode_at(i) >= 65 and text.unicode_at(i) <= 90:
			new_text += String.chr(((text.unicode_at(i)-65 + 11) % 26) + 65)
		elif text.unicode_at(i) >= 97 and text.unicode_at(i) <= 122:
			new_text += String.chr(((text.unicode_at(i)-97 + 11) % 26) + 97)
		elif text.unicode_at(i) >= 48 and text.unicode_at(i) <= 57:
			new_text += String.chr(((text.unicode_at(i)-48 + 11) % 10) + 48)
		else:
			new_text += text[i]
	return new_text

func decrypt_string(text: String) -> String:
	var new_text: String = ""
	for i in range(text.length()):
		if text.unicode_at(i) >= 65 and text.unicode_at(i) <= 90:
			new_text += String.chr(((text.unicode_at(i)-65 + 15) % 26) + 65)
		elif text.unicode_at(i) >= 97 and text.unicode_at(i) <= 122:
			new_text += String.chr(((text.unicode_at(i)-97 + 15) % 26) + 97)
		elif text.unicode_at(i) >= 48 and text.unicode_at(i) <= 57:
			new_text += String.chr(((text.unicode_at(i)-48 + 9) % 10) + 48)
		else:
			new_text += text[i]
	return new_text
