extends Control

const USER_PREF_PATH: String = "user://user_preferences.json"

@onready var customer_line = get_node("VBoxContainer/CustomerLine")

var user_preferences: UserPreferences
#var path: String = "F:/"
var project_name: String = "A"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	user_preferences = UserPreferences.load_from_file(USER_PREF_PATH)
	update_controls()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_controls() -> void:
	if not user_preferences.has_default_path:
		get_node("VBoxContainer/GenerateFolderButton").disabled = true
	else:
		get_node("VBoxContainer/GenerateFolderButton").disabled = false
	
	
	
	#print(DirAccess.get_directories_at(user_preferences.default_path))
	
	get_node("VBoxContainer/Label").text = ""
	customer_line.get_node("CustomerOption").clear()
	customer_line.get_node("CustomerOption").add_item("<New customer>")
	for d in DirAccess.get_directories_at(user_preferences.default_path):
		get_node("VBoxContainer/Label").text += d + "\n"
		customer_line.get_node("CustomerOption").add_item(d)

func _on_choose_folder_button_pressed() -> void:
	PrintUtility.print_info("User trying to choose folder ...")
	get_node("FileDialog").set_current_dir(user_preferences.default_path)
	get_node("FileDialog").visible = true

func _on_save_pref_button_pressed() -> void:
	PrintUtility.print_WIP("Save preferences to JSON file ...")
	user_preferences.save_to_file(USER_PREF_PATH)

func _on_file_dialog_dir_selected(dir: String) -> void:
	PrintUtility.print_info("Selected folder is : " + dir + "/")
	user_preferences.default_path = dir
	user_preferences.has_default_path = true
	update_controls()

func _on_file_dialog_canceled() -> void:
	PrintUtility.print_info("User cancelled folder choice")

func _on_generate_folder_button_pressed() -> void:
	PrintUtility.print_info("Start generating folders ...")
	var result = DirAccess.make_dir_absolute(user_preferences.default_path + "/" + project_name)
	match result:
		0:
			PrintUtility.print_info("Success")
		32:
			PrintUtility.print_error("Folder already exists")
		_:
			PrintUtility.print_error("Unkown error : " + str(result))
	print(result)


func _on_customer_option_item_selected(index: int) -> void:
	if index == 0:
		customer_line.get_node("CustomerEdit").visible = true
	else:
		print(customer_line.get_node("CustomerEdit"))
		customer_line.get_node("CustomerEdit").visible = false
