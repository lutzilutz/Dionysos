extends Control

const SAVE_PREFERENCES_PATH: String = "user://preferences.json"
const SAVE_USERS_PATH: String = "user://users.json"

@export var checked_color: Color = Color(0,1,0)
@export var warning_color: Color = Color(1,0.5,0)

var empty_texture: Texture2D = preload("res://resources/icons/empty_16.png")
var error_texture: Texture2D = preload("res://resources/icons/cancel_16.png")
var checked_texture: Texture2D = preload("res://resources/icons/checked_16.png")
var information_texture: Texture2D = preload("res://resources/icons/information_16.png")

@onready var tutorial = get_node("Tutorial")
@onready var splashscreen = get_node("Splashscreen")

@onready var edit_menu = get_node("Window/MenuContainer/MenuBar/EditMenu")
@onready var background_logo_sprite = get_node("BackgroundLogoSprite")
@onready var preferences_dialog = get_node("PreferencesDialog")
@onready var tabs_manager = get_node("Window/Workspace/TabsManager")
@onready var folder_manager = get_node("Window/Workspace/FolderManager")
@onready var user_manager = get_node("Window/Workspace/UserManager")

@onready var workspace_title = get_node("Window/MenuContainer/WorkspaceTitle")
@onready var version_label = get_node("VersionLabel")

var user_preferences: UserPreferences
var users: Users

func check_if_release() -> void:
	if OS.has_feature("editor"):
		PrintUtility.print_info("Running from editor")
	elif OS.has_feature("release"):
		PrintUtility.print_info("Running from release build")
	elif OS.has_feature("debug"):
		PrintUtility.print_info("Running from debug build")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_if_release()
	version_label.set_text("Version " + ProjectSettings.get_setting("application/config/version"))
	user_preferences = UserPreferences.load_from_file(SAVE_PREFERENCES_PATH)
	users = Users.load_from_file(SAVE_USERS_PATH)
	user_manager.main_scene = self
	user_manager.build_users()
	user_manager.users_changed.connect(_on_user_manager_users_changed)
	
	# Read-me init -----
	folder_manager.init(self)
	
	tutorial.tutorial_ended.connect(_on_tutorial_ended)
	update_tutorial_screen()
	update_edit_folder_follow_conventions()
	update_edit_hide_logo()
	update_edit_show_highlights()
	update_preferences_dialog()
	tabs_manager.ask_tab_change.connect(_on_tabs_manager_change)

func _on_tabs_manager_change(type) -> void:
	if type == TabButton.TabType.FOLDER_MANAGER:
		workspace_title.text = "Générateur de dossiers"
		folder_manager.visible = true
		user_manager.visible = false
	elif type == TabButton.TabType.USER_MANAGER:
		workspace_title.text = "Gestionnaire des utilisateurs"
		folder_manager.visible = false
		user_manager.visible = true

func update_preferences_dialog() -> void:
	var label = get_node("PreferencesDialog/PreferencesLabel")
	label.text = "Chemin du dossier : " + user_preferences.default_path
	label.text += "\nA un chemin : " + str(user_preferences.has_default_path)
	label.text += "\nDossier suit conventions : " + str(user_preferences.folder_follow_conventions)
	label.text += "\nCacher logo : " + str(user_preferences.hide_logo)
	label.text += "\nAfficher surlignage : " + str(user_preferences.show_highlights)
	label.text += "\nA vu le tutoriel : " + str(user_preferences.has_seen_tutorial)

func _on_tutorial_ended() -> void:
	user_preferences.has_seen_tutorial = true
	user_preferences.save_to_file(SAVE_PREFERENCES_PATH)
	update_tutorial_screen()

func update_tutorial_screen() -> void:
	tutorial.reset_tutorial()
	tutorial.visible = not user_preferences.has_seen_tutorial

func _on_save_pref_button_pressed() -> void:
	PrintUtility.print_WIP("Save preferences to JSON file ...")
	user_preferences.save_to_file(SAVE_PREFERENCES_PATH)

# MenuBar signals =================================================================================

func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		0: # Quit
			PrintUtility.print_info("Quitting the software ...")
			get_tree().quit()
		1: # Start new project
			folder_manager.reset_project()
		2: # Open saves folder
			OS.shell_open(OS.get_user_data_dir())
		4: # Open github releases
			OS.shell_open("https://github.com/lutzilutz/Dionysos/releases")
		6: # Import users file
			users.import_from_file("")
		_:
			PrintUtility.print_info("Unkown file menu option")

func _on_edit_menu_id_pressed(id: int) -> void:
	match id:
		0: # Reset preferences
			PrintUtility.print_info("Reset preferences")
			user_preferences.reset_user_preferences(SAVE_PREFERENCES_PATH)
			folder_manager.project_name = ""
			folder_manager.customer_name = ""
			update_edit_folder_follow_conventions()
			update_edit_hide_logo()
			update_edit_show_highlights()
			folder_manager.update_controls()
		1: # Hide logo
			user_preferences.hide_logo = not user_preferences.hide_logo
			user_preferences.save_to_file(SAVE_PREFERENCES_PATH)
			update_edit_hide_logo()
		2: # Show highlight
			user_preferences.show_highlights = not user_preferences.show_highlights
			user_preferences.save_to_file(SAVE_PREFERENCES_PATH)
			update_edit_show_highlights()
		4: # Show preferences summary
			update_preferences_dialog()
			preferences_dialog.visible = true
		5: # Purge editors
			users.editors = []
			users.purge_editors()
			users.save_to_file(SAVE_USERS_PATH)
			users.build_users()
			folder_manager.build_editor_options()
		6: # Purge customers
			users.customers = []
			users.purge_customers()
			users.save_to_file(SAVE_USERS_PATH)
			folder_manager.build_customer_options()
		7: # Folder only contains customers
			user_preferences.folder_follow_conventions = not user_preferences.folder_follow_conventions
			user_preferences.save_to_file(SAVE_PREFERENCES_PATH)
			update_edit_folder_follow_conventions()
		_:
			PrintUtility.print_info("Unkown edition menu option")

func _on_help_menu_id_pressed(id: int) -> void:
	match id:
		0: # Help-me
			pass
		1: # Rewatch tutorial
			user_preferences.has_seen_tutorial = false
			user_preferences.save_to_file(SAVE_PREFERENCES_PATH)
			update_tutorial_screen()
		2: # Splashscreen
			splashscreen.enable(true)
		_: #
			PrintUtility.print_info("Unkown help menu option")

func update_edit_folder_follow_conventions() -> void:
	edit_menu.set_item_checked(edit_menu.get_item_index(7), user_preferences.folder_follow_conventions)
	PrintUtility.print_TODO("Update according to folder_follow_conventions")
	folder_manager.build_customer_options()
	folder_manager.customer_name = ""
	folder_manager.update_controls()

func update_edit_hide_logo() -> void:
	edit_menu.set_item_checked(edit_menu.get_item_index(1), user_preferences.hide_logo)
	background_logo_sprite.visible = not user_preferences.hide_logo

func update_edit_show_highlights() -> void:
	edit_menu.set_item_checked(edit_menu.get_item_index(2), user_preferences.show_highlights)
	if not user_preferences.show_highlights:
		folder_manager.reset_tree_highlights()

func _on_user_manager_users_changed() -> void:
	folder_manager.build_editor_options()
	folder_manager.build_customer_options()
	folder_manager.editor_name = ""
	folder_manager.customer_name = ""
	folder_manager.update_controls()

# =================================================================================================

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("PrintFolders"):
		PrintUtility.print_folders(folder_manager.folder_tree)

func _on_import_dialog_file_selected(path: String) -> void:
	users.import_from_file(path)
	users.save_to_file(SAVE_USERS_PATH)
	user_manager.build_users()
	folder_manager.build_editor_options()
	folder_manager.build_customer_options()
