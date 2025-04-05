class_name Users extends Resource

const EDITORS_INCODE: Array = []
const EDITORS_INFILE: Dictionary = {}
const CUSTOMERS: Array = []

const LUTZ_NAME: String = "Wfekt Wfek"
const LUTZ_PHONE: String = "180 263 15 06"
const LUTZ_EMAIL: String = "wfek@ocjvled.ns"
const YANN_NAME: String = "Jlyy Xlezfdpv"
const YANN_PHONE: String = "187 481 34 19"
const YANN_EMAIL: String = "jlyy.xlezfdpv@ocjvled.ns"
const KAREL_NAME: String = "Vlcpw Xlezfdpv"
const KAREL_PHONE: String = "187 481 33 70"
const KAREL_EMAIL: String = "vlcpw.xlezfdpv@ocjvled.ns"

@export var all_users: Array = []
#@export var customers: Array = []

func save_to_file(path:String) -> Error:
	var json_editors:Dictionary = {}
	var json_customers:Dictionary = {}
	# Build Editor resources
	for e: User in all_users:
		var json_infos: Dictionary = {
			"phone": e.phone,
			"email": e.email
		}
		if e.function == DataManager.UserFunction.EDITOR:
			json_editors[e.name] = json_infos
		elif e.function == DataManager.UserFunction.CUSTOMER:
			json_editors[e.name] = json_infos
		else:
			PrintUtility.print_error("Unknown DataManager.UserFunction value in save_to_file(" + path + ")")
	#for e: User in customers:
		#var json_infos: Dictionary = {
			#"phone": e.phone,
			#"email": e.email
		#}
		#json_customers[e.name] = json_infos
	# Build main resources
	var json = {
		"version": ProjectSettings.get_setting("application/config/version"),
		"editors": json_editors,
		"customers": json_customers
	}
	var file = FileAccess.open(path, FileAccess.WRITE)

	if file:
		file.store_string(JSON.stringify(json, "\t"))
		file.flush()
		return OK
	else:
		return ERR_FILE_CANT_WRITE

func purge_editors() -> void:
	var tmp_users: Array = []
	for u in all_users:
		if u.function != DataManager.UserFunction.EDITOR:
			tmp_users.append(u)
	all_users = tmp_users
	add_editor(decrypt_string(KAREL_NAME), decrypt_string(KAREL_PHONE), decrypt_string(KAREL_EMAIL))
	add_editor(decrypt_string(LUTZ_NAME), decrypt_string(LUTZ_PHONE), decrypt_string(LUTZ_EMAIL))
	add_editor(decrypt_string(YANN_NAME), decrypt_string(YANN_PHONE), decrypt_string(YANN_EMAIL))

func purge_customers() -> void:
	var tmp_users: Array = []
	for u in all_users:
		if u.function != DataManager.UserFunction.CUSTOMER:
			tmp_users.append(u)
	all_users = tmp_users

static func generate_drykats_team() -> Dictionary:
	var d: Dictionary
	d[decrypt_string(LUTZ_NAME)] = {
		"phone": decrypt_string(LUTZ_PHONE),
		"email": decrypt_string(LUTZ_EMAIL)
	}
	d[decrypt_string(YANN_NAME)] = {
		"phone": decrypt_string(YANN_PHONE),
		"email": decrypt_string(YANN_EMAIL)
	}
	d[decrypt_string(KAREL_NAME)] = {
		"phone": decrypt_string(KAREL_PHONE),
		"email": decrypt_string(KAREL_EMAIL)
	}
	return d

static func generate_drykats_customers() -> Dictionary:
	var d: Dictionary
	d["Nepsa"] = {
		"phone": "",
		"email": ""
	}
	return d

static func load_from_file(path: String) -> Users:
	# Check if a users file already exists (not first time)
	# If not, creates a default JSON file to be used
	if not FileAccess.file_exists(path):
		PrintUtility.print_info("No users.json found")
		var new_file = FileAccess.open(path, FileAccess.WRITE)
		var new_json = {
			"version": ProjectSettings.get_setting("application/config/version"),
			"editors": generate_drykats_team(),
			"customers": generate_drykats_customers()
		}
		if new_file:
			new_file.store_string(JSON.stringify(new_json, "\t"))
			new_file.flush()
			PrintUtility.print_info("Successful creation of users.json")
		else:
			PrintUtility.print_error("Can't write a new file users.json")
			PrintUtility.print_error(str(FileAccess.get_open_error()))
	else:
		PrintUtility.print_info("users.json found")
	
	# Actual loading of the file into Users resource
	PrintUtility.print_info("Loading users.json ...")
	var file = FileAccess.get_file_as_string(path)
	var json = JSON.parse_string(file) as Dictionary
	var res = Users.new()
	var tmp_editors: Dictionary = json.get("editors", EDITORS_INFILE)
	if tmp_editors != null :
		for e_name in tmp_editors.keys():
			var tmp_editor: User = User.new()
			tmp_editor.name = e_name
			tmp_editor.phone = tmp_editors[e_name].get("phone", "")
			tmp_editor.email = tmp_editors[e_name].get("email", "")
			tmp_editor.function = DataManager.UserFunction.EDITOR
			res.all_users.append(tmp_editor)
	
	var tmp_customers: Dictionary = json.get("customers", EDITORS_INFILE)
	#print(tmp_customers)
	if tmp_customers != null :
		for e_name in tmp_customers.keys():
			var tmp_customer: User = User.new()
			tmp_customer.name = e_name
			tmp_customer.phone = tmp_customers[e_name].get("phone", "")
			tmp_customer.email = tmp_customers[e_name].get("email", "")
			tmp_customer.function = DataManager.UserFunction.CUSTOMER
			res.all_users.append(tmp_customer)
	
	if json.get("version", "") != ProjectSettings.get_setting("application/config/version"):
		PrintUtility.print_info("Current users.json is version " + json.get("version", "") + " but Dionysos is version " + ProjectSettings.get_setting("application/config/version"))
		PrintUtility.print_TODO("Manage upgrade of users.json")
	return res

func editor_exists(new_name: String) -> bool:
	var editor_found: bool = false
	for u in all_users:
		if u.function == DataManager.UserFunction.EDITOR:
			if u.name.capitalize() == new_name.capitalize():
				editor_found = true
				break
	return editor_found

func customer_exists(new_name: String) -> bool:
	var customer_found: bool = false
	for u in all_users:
		if u.function == DataManager.UserFunction.CUSTOMER:
			if u.name.capitalize() == new_name.capitalize():
				customer_found = true
				break
	return customer_found

func add_editor(name: String, phone: String, email: String) -> void:
	var editor: User = User.new()
	editor.name = name
	editor.phone = phone
	editor.email = email
	editor.function = DataManager.UserFunction.EDITOR
	if all_users.is_read_only():
		PrintUtility.print_error("users.all_users is in read-only state")
	all_users.append(editor)

func change_editor(name: String, phone: String, email: String) -> void:
	var new_editor: User = User.new()
	new_editor.name = name
	new_editor.phone = phone
	new_editor.email = email
	for u in all_users:
		if u.function == DataManager.UserFunction.EDITOR:
			if u.name.capitalize() == name.capitalize():
				if new_editor.name != u.name or new_editor.phone != u.phone or new_editor.email != u.email:
					PrintUtility.print_info("User changing editor infos, from, to :")
					PrintUtility.print_info(u.name + " - " + u.phone + " - " + u.email)
					PrintUtility.print_info(name + " - " + phone + " - " + email)
				u.name = name
				u.phone = phone
				u.email = email

func get_editor_from_name(name: String) -> User:
	var tmp_editor: User = null
	for u in all_users:
		if u.function == DataManager.UserFunction.EDITOR:
			if u.name.capitalize() == name.capitalize():
				return u
	return tmp_editor

func get_user_from_name(name: String) -> User:
	var tmp_editor: User = null
	for u in all_users:
		if u.name.capitalize() == name.capitalize():
			return u
	return tmp_editor

func remove_editor(index: int) -> void:
	all_users.remove_at(index)

static func encrypt_string(text: String) -> String:
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

static func decrypt_string(text: String) -> String:
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
