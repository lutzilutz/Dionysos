extends Control

enum ProductionType {
	EXTERNAL,
	INTERNAL
}

const USER_PREF_PATH: String = "user://user_preferences.json"

@onready var form_vbox = get_node("WorkspaceHBox/FormVBox")
@onready var customer_line = get_node("WorkspaceHBox/FormVBox/CustomerLine")
@onready var customer_option = get_node("WorkspaceHBox/FormVBox/CustomerLine/CustomerOption")
@onready var customer_edit = get_node("WorkspaceHBox/FormVBox/CustomerLine/CustomerEdit")
@onready var project_name_edit = get_node("WorkspaceHBox/FormVBox/ProjectNameLine/ProjectNameEdit")
@onready var production_type_option = get_node("WorkspaceHBox/FormVBox/ProductionTypeLine/ProductionTypeOption")
@onready var generate_folder_button = get_node("WorkspaceHBox/FormVBox/ChooseFolderButton")
@onready var summary_label = get_node("WorkspaceHBox/SummaryLabel")

var user_preferences: UserPreferences
var customer_name: String = ""
var project_name: String = ""
var production_type: ProductionType = ProductionType.EXTERNAL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	user_preferences = UserPreferences.load_from_file(USER_PREF_PATH)
	update_controls()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_controls() -> void:
	if not user_preferences.has_default_path:
		generate_folder_button.disabled = true
	else:
		generate_folder_button.disabled = false
	
	customer_option.clear()
	customer_option.add_item("<New customer>")
	for d in DirAccess.get_directories_at(user_preferences.default_path):
		customer_option.add_item(d)

func update_summary() -> void:
	summary_label.text = "Customer name : " + customer_name
	if DirAccess.dir_exists_absolute(user_preferences.default_path + "/" + customer_name):
		if DirAccess.get_directories_at(user_preferences.default_path + "/" + customer_name).size() == 0:
			print("No project")
		else:
			form_vbox.get_node("Label").text = ""
			for d in DirAccess.get_directories_at(user_preferences.default_path + "/" + customer_name):
				form_vbox.get_node("Label").text += "\n" + d
	
	summary_label.text += "\n" + "Project name : " + project_name_edit.text
	
	if production_type_option.selected > -1:
		if production_type == ProductionType.EXTERNAL:
			summary_label.text += "\n" + "External project"
		else:
			summary_label.text += "\n" + "Internal project"

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

func _on_customer_option_item_selected(index: int) -> void:
	if index == 0:
		customer_edit.visible = true
		customer_name = customer_edit.text
	else:
		customer_edit.visible = false
		customer_name = customer_option.get_item_text(index)
	update_summary()

func _on_customer_edit_text_changed(new_text: String) -> void:
	customer_name = new_text
	update_summary()

func _on_project_name_edit_text_changed(new_text: String) -> void:
	update_summary()

func _on_production_type_option_item_selected(index: int) -> void:
	match index:
		0:
			production_type = ProductionType.EXTERNAL
		1:
			production_type = ProductionType.INTERNAL
	update_summary()
