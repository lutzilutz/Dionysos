extends Control

const USER_PREF_PATH: String = "user://user_preferences.json"

var user_preferences: UserPreferences
var path: String = "F:/"
var project_name: String = "A"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	user_preferences = UserPreferences.load_from_file(USER_PREF_PATH)
	update_controls()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_controls() -> void:
	
	pass

func _on_choose_folder_button_pressed() -> void:
	PrintUtility.print_info("User trying to choose folder ...")
	get_node("FileDialog").set_current_dir(path)
	get_node("FileDialog").visible = true

func _on_save_pref_button_pressed() -> void:
	PrintUtility.print_WIP("Save preferences to JSON file ...")
	#user_preferences.default_path = get_node("FileDialog").current_dir
	#print(get_node("FileDialog").current_dir)
	user_preferences.save_to_file(USER_PREF_PATH)

func _on_file_dialog_dir_selected(dir: String) -> void:
	PrintUtility.print_info("Selected folder is : " + dir + "/")
	user_preferences.default_path = dir
	user_preferences.has_default_path = true

func _on_file_dialog_canceled() -> void:
	PrintUtility.print_info("User cancelled folder choice")

func _on_generate_folder_button_pressed() -> void:
	PrintUtility.print_info("Start generating folders ...")
	var result = DirAccess.make_dir_absolute(path + "/" + project_name)
	match result:
		0:
			PrintUtility.print_info("Success")
		32:
			PrintUtility.print_error("Folder already exists")
	print(result)
