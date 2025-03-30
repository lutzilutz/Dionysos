extends Control

enum ProductionType {
	EXTERNAL,
	INTERNAL
}

const USER_PREF_PATH: String = "user://user_preferences.json"

var FolderLabel = preload("res://scenes/folder_label.tscn")

@onready var form_vbox = get_node("WorkspaceHBox/FormVBox")
@onready var customer_line = get_node("WorkspaceHBox/FormVBox/CustomerLine")
@onready var customer_label = get_node("WorkspaceHBox/FormVBox/CustomerLine/CustomerLabel")
@onready var customer_option = get_node("WorkspaceHBox/FormVBox/CustomerLine/CustomerOption")
@onready var customer_edit = get_node("WorkspaceHBox/FormVBox/CustomerLine/CustomerEdit")
@onready var project_name_label = get_node("WorkspaceHBox/FormVBox/ProjectNameLine/ProjectNameLabel")
@onready var project_name_edit = get_node("WorkspaceHBox/FormVBox/ProjectNameLine/ProjectNameEdit")
@onready var production_type_label = get_node("WorkspaceHBox/FormVBox/ProductionTypeLine/ProductionTypeLabel")
@onready var production_type_option = get_node("WorkspaceHBox/FormVBox/ProductionTypeLine/ProductionTypeOption")
@onready var preview_folder_button = get_node("WorkspaceHBox/FormVBox/PreGenerateFolderButton")
@onready var generate_folder_button = get_node("WorkspaceHBox/FormVBox/GenerateFolderButton")
@onready var summary_vbox = get_node("WorkspaceHBox/SummaryVBox")
@onready var summary_label = get_node("WorkspaceHBox/SummaryVBox/SummaryLabel")
@onready var summary_folders_vbox = get_node("WorkspaceHBox/SummaryVBox/SummaryFoldersVBox")

var user_preferences: UserPreferences
var customer_name: String = ""
var project_name: String = ""
var production_type: ProductionType
var has_previewed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	user_preferences = UserPreferences.load_from_file(USER_PREF_PATH)
	update_controls()
	generate_folders_label()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func generate_folders_label() -> void:
	for c in summary_folders_vbox.get_children():
		c.queue_free()
	add_new_folder("01 Preproduction")
	add_new_folder("02 Production")
	add_new_folder("03 Audio")
	add_new_folder("          Production audio")
	add_new_folder("          SFX")
	add_new_folder("          Sound track")
	add_new_folder("04 Footage")
	add_new_folder("05 VFX")
	add_new_folder("06 Assets")
	add_new_folder("07 Working renders")
	if production_type == ProductionType.EXTERNAL:
		add_new_folder("          Offline drafts")
		add_new_folder("          Online drafts")
	else:
		add_new_folder("          Drafts")
	add_new_folder("08 Final renders")
	add_new_folder("09 Working edit files")
	add_new_folder("10 DaVinci project archive")
	add_new_folder("11 Notes")
	add_new_folder("00 Vous etes ici - lisez-moi.txt")

func add_new_folder(text: String) -> void:
	var temp_label = FolderLabel.instantiate()
	temp_label.text = text
	summary_folders_vbox.add_child(temp_label)

func update_controls() -> void:
	# Updating form controls depending how much user has filled it
	
	# Customer name
	customer_label.disable(not user_preferences.has_default_path)
	customer_option.disabled = not user_preferences.has_default_path
	customer_edit.editable = user_preferences.has_default_path
	
	# Project name
	project_name_label.disable(not (user_preferences.has_default_path and customer_name != ""))
	project_name_edit.editable = user_preferences.has_default_path and customer_name != ""
	
	# Production type
	production_type_label.disable(not (user_preferences.has_default_path and customer_name != "" and project_name != ""))
	production_type_option.disabled = not (user_preferences.has_default_path and customer_name != "" and project_name != "")
	
	# Buttons
	preview_folder_button.disabled = not (user_preferences.has_default_path and customer_name != "" and project_name != "" and production_type_option.selected != -1)
	generate_folder_button.disabled = not (user_preferences.has_default_path and customer_name != "" and project_name != "" and production_type_option.selected != -1 and has_previewed)
	
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
	
	summary_label.text += "\n" + "Project name : " + project_name
	
	if production_type_option.selected > -1:
		if production_type == ProductionType.EXTERNAL:
			summary_label.text += "\n" + "External project"
		else:
			summary_label.text += "\n" + "Internal project"
	
	summary_label.text += "\n"

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
	user_preferences.save_to_file(USER_PREF_PATH)
	update_controls()

func _on_file_dialog_canceled() -> void:
	PrintUtility.print_info("User cancelled folder choice")

func _on_pre_generate_folder_button_pressed() -> void:
	PrintUtility.print_info("Start pre-generating folders ...")
	
	for i in range(summary_folders_vbox.get_child_count()):
		summary_folders_vbox.get_child(i).delay = i * (2.0 / summary_folders_vbox.get_child_count())
	
	for e in summary_folders_vbox.get_children():
		e.activate()
	summary_vbox.get_node("TestLabel").activate()
	
	has_previewed = true
	update_controls()

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
	update_controls()
	update_summary()

func _on_customer_edit_text_changed(new_text: String) -> void:
	customer_name = new_text
	update_controls()
	update_summary()

func _on_project_name_edit_text_changed(new_text: String) -> void:
	project_name = new_text
	update_controls()
	update_summary()

func _on_production_type_option_item_selected(index: int) -> void:
	match index:
		0:
			production_type = ProductionType.EXTERNAL
		1:
			production_type = ProductionType.INTERNAL
	update_controls()
	update_summary()
	generate_folders_label()
