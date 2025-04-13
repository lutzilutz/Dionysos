class_name Users extends Resource

signal users_imported(imported_count: int, imported_users: String, changed_count: int, changed_users: String)

const EDITORS_INCODE: Array = []
const EDITORS_INFILE: Dictionary = {}
const CUSTOMERS: Array = []

@export var all_users: Array = []

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
			json_customers[e.name] = json_infos
		else:
			PrintUtility.print_error("Unknown DataManager.UserFunction value in save_to_file(" + path + ")")
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

func purge_customers() -> void:
	var tmp_users: Array = []
	for u in all_users:
		if u.function != DataManager.UserFunction.CUSTOMER:
			tmp_users.append(u)
	all_users = tmp_users

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
			"editors": {},
			"customers": {}
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
	var editor_loaded_count: int = 0
	var customer_loaded_count: int = 0
	var file = FileAccess.get_file_as_string(path)
	var json = JSON.parse_string(file) as Dictionary
	var res = Users.new()
	var tmp_editors: Dictionary = json.get("editors", EDITORS_INFILE)
	if tmp_editors != null :
		for e_name in tmp_editors.keys():
			editor_loaded_count += 1
			var tmp_editor: User = User.new()
			tmp_editor.name = e_name
			tmp_editor.phone = tmp_editors[e_name].get("phone", "")
			tmp_editor.email = tmp_editors[e_name].get("email", "")
			tmp_editor.function = DataManager.UserFunction.EDITOR
			res.all_users.append(tmp_editor)
	
	var tmp_customers: Dictionary = json.get("customers", EDITORS_INFILE)
	if tmp_customers != null :
		for e_name in tmp_customers.keys():
			customer_loaded_count += 1
			var tmp_customer: User = User.new()
			tmp_customer.name = e_name
			tmp_customer.phone = tmp_customers[e_name].get("phone", "")
			tmp_customer.email = tmp_customers[e_name].get("email", "")
			tmp_customer.function = DataManager.UserFunction.CUSTOMER
			res.all_users.append(tmp_customer)
	
	PrintUtility.print_info("Loaded " + str(editor_loaded_count) + " editors and " + str(customer_loaded_count) + " customers")
	
	if json.get("version", "") != ProjectSettings.get_setting("application/config/version"):
		PrintUtility.print_info("Current users.json is version " + json.get("version", "") + " but Dionysos is version " + ProjectSettings.get_setting("application/config/version"))
		PrintUtility.print_TODO("Manage upgrade of users.json")
	return res

func import_from_file(path: String) -> void:
	var imported_count: int = 0
	var imported_users: String = ""
	var changed_count: int = 0
	var changed_users: String = ""
	if not FileAccess.file_exists(path):
		PrintUtility.print_error("File doesn't appear to exist : " + path)
	else:
		# Actual loading of the file into Users resource
		PrintUtility.print_info("Importing " + path + " ...")
		var editor_loaded_count: int = 0
		var customer_loaded_count: int = 0
		var file = FileAccess.get_file_as_string(path)
		var json = JSON.parse_string(file) as Dictionary
		var tmp_editors: Dictionary = json.get("editors", EDITORS_INFILE)
		if tmp_editors != null :
			for e_name in tmp_editors.keys():
				var has_duplicate: bool = false
				# Check if user already exists in database
				for u in all_users:
					if u.function == DataManager.UserFunction.EDITOR:
						if u.name == e_name:
							PrintUtility.print_info("Found matching editor " + u.name + ", changing it")
							has_duplicate = true
							u.phone = tmp_editors[e_name].get("phone", "")
							u.email = tmp_editors[e_name].get("email", "")
							changed_count += 1
							changed_users += u.name + " - " + u.phone + " - " + u.email + "\n"
				
				if not has_duplicate:
					var tmp_editor: User = User.new()
					tmp_editor.name = e_name
					tmp_editor.phone = tmp_editors[e_name].get("phone", "")
					tmp_editor.email = tmp_editors[e_name].get("email", "")
					tmp_editor.function = DataManager.UserFunction.EDITOR
					all_users.append(tmp_editor)
					imported_count += 1
					imported_users += tmp_editor.name + " - " + tmp_editor.phone + " - " + tmp_editor.email + "\n"
				editor_loaded_count += 1
		
		var tmp_customers: Dictionary = json.get("customers", EDITORS_INFILE)
		if tmp_customers != null :
			for e_name in tmp_customers.keys():
				var has_duplicate: bool = false
				# Check if user already exists in database
				for u in all_users:
					if u.function == DataManager.UserFunction.CUSTOMER:
						if u.name == e_name:
							PrintUtility.print_info("Found matching customer " + u.name + ", changing it")
							has_duplicate = true
							u.phone = tmp_customers[e_name].get("phone", "")
							u.email = tmp_customers[e_name].get("email", "")
							changed_count += 1
							changed_users += u.name + " - " + u.phone + " - " + u.email + "\n"
				
				if not has_duplicate:
					var tmp_customer: User = User.new()
					tmp_customer.name = e_name
					tmp_customer.phone = tmp_customers[e_name].get("phone", "")
					tmp_customer.email = tmp_customers[e_name].get("email", "")
					tmp_customer.function = DataManager.UserFunction.CUSTOMER
					all_users.append(tmp_customer)
					imported_count += 1
					imported_users += tmp_customer.name + " - " + tmp_customer.phone + " - " + tmp_customer.email + "\n"
				customer_loaded_count += 1
		
		PrintUtility.print_info("Imported " + str(editor_loaded_count) + " editors and " + str(customer_loaded_count) + " customers")
		
		if json.get("version", "") != ProjectSettings.get_setting("application/config/version"):
			PrintUtility.print_info("Current json is version " + json.get("version", "") + " but Dionysos is version " + ProjectSettings.get_setting("application/config/version"))
	if imported_users.unicode_at(imported_users.length()-1) == 10 or imported_users.unicode_at(imported_users.length()-1) == 13:
		imported_users = imported_users.left(imported_users.length()-1)
	
	users_imported.emit(imported_count, imported_users, changed_count, changed_users)

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

func add_user(function: DataManager.UserFunction, name: String, phone: String, email: String) -> void:
	var user: User = User.new()
	user.name = name
	user.phone = phone
	user.email = email
	user.function = function
	if all_users.is_read_only():
		PrintUtility.print_error("users.all_users is in read-only state")
	all_users.append(user)

func add_editor(name: String, phone: String, email: String) -> void:
	var editor: User = User.new()
	editor.name = name
	editor.phone = phone
	editor.email = email
	editor.function = DataManager.UserFunction.EDITOR
	if all_users.is_read_only():
		PrintUtility.print_error("users.all_users is in read-only state")
	all_users.append(editor)

func change_user(new_user: User) -> void:
	var found_user_to_change: bool = false
	for u in all_users:
		if u.is_same_as(new_user):
			if new_user.name != u.name or new_user.phone != u.phone or new_user.email != u.email:
				PrintUtility.print_info("User changing editor infos, from, to :")
				PrintUtility.print_info(u.name + " - " + u.phone + " - " + u.email)
				PrintUtility.print_info(new_user.name + " - " + new_user.phone + " - " + new_user.email)
				u.name = new_user.name
				u.phone = new_user.phone
				u.email = new_user.email
				found_user_to_change = true
	if not found_user_to_change:
		PrintUtility.print_error("Didn't find user to change in users.change_user()")

func get_user_from_name(function: DataManager.UserFunction, name: String) -> User:
	var tmp_user: User = null
	for u in all_users:
		if u.function == function and u.name.capitalize() == name.capitalize():
			return u
	PrintUtility.print_info("Didn't find user [" + name + "] with function " + str(function) + " in users.get_user_from_name()")
	return tmp_user

func remove_editor(index: int) -> void:
	all_users.remove_at(index)

func remove_user(user: User) -> void:
	var index_to_remove: int = -1
	for i in range(all_users.size()):
		if all_users[i].is_same_as(user):
			index_to_remove = i
	if index_to_remove != -1:
		all_users.remove_at(index_to_remove)
	else:
		PrintUtility.print_error("Couldn't find user in users.remove_user(user)")

#static func encrypt_string(text: String) -> String:
	#var new_text: String = ""
	#for i in range(text.length()):
		#if text.unicode_at(i) >= 65 and text.unicode_at(i) <= 90:
			#new_text += String.chr(((text.unicode_at(i)-65 + 11) % 26) + 65)
		#elif text.unicode_at(i) >= 97 and text.unicode_at(i) <= 122:
			#new_text += String.chr(((text.unicode_at(i)-97 + 11) % 26) + 97)
		#elif text.unicode_at(i) >= 48 and text.unicode_at(i) <= 57:
			#new_text += String.chr(((text.unicode_at(i)-48 + 11) % 10) + 48)
		#else:
			#new_text += text[i]
	#return new_text
#
#static func decrypt_string(text: String) -> String:
	#var new_text: String = ""
	#for i in range(text.length()):
		#if text.unicode_at(i) >= 65 and text.unicode_at(i) <= 90:
			#new_text += String.chr(((text.unicode_at(i)-65 + 15) % 26) + 65)
		#elif text.unicode_at(i) >= 97 and text.unicode_at(i) <= 122:
			#new_text += String.chr(((text.unicode_at(i)-97 + 15) % 26) + 97)
		#elif text.unicode_at(i) >= 48 and text.unicode_at(i) <= 57:
			#new_text += String.chr(((text.unicode_at(i)-48 + 9) % 10) + 48)
		#else:
			#new_text += text[i]
	#return new_text
