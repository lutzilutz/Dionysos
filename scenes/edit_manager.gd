extends Control

func _ready() -> void:
	get_node("ProjectSummary").open_folder.connect(_on_open_folder_pressed)

func _on_open_folder_pressed() -> void:
	get_node("FileDialog").visible = true

#func save_to_file(path:String) -> Error:
	#var json_editors:Dictionary = {}
	#var json_customers:Dictionary = {}
	## Build Editor resources
	#for e: User in all_users:
		#var json_infos: Dictionary = {
			#"phone": e.phone,
			#"email": e.email
		#}
		#if e.function == DataManager.UserFunction.EDITOR:
			#json_editors[e.name] = json_infos
		#elif e.function == DataManager.UserFunction.CUSTOMER:
			#json_customers[e.name] = json_infos
		#else:
			#PrintUtility.print_error("Unknown DataManager.UserFunction value in save_to_file(" + path + ")")
	## Build main resources
	#var json = {
		#"version": ProjectSettings.get_setting("application/config/version"),
		#"editors": json_editors,
		#"customers": json_customers
	#}
	#var file = FileAccess.open(path, FileAccess.WRITE)
#
	#if file:
		#file.store_string(JSON.stringify(json, "\t"))
		#file.flush()
		#return OK
	#else:
		#return ERR_FILE_CANT_WRITE


func _on_file_dialog_dir_selected(dir: String) -> void:
	DirAccess.dir_exists_absolute(dir)
	
