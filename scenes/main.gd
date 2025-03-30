extends Control

enum ProductionType {
	EXTERNAL,
	INTERNAL
}

const USER_PREF_PATH: String = "user://user_preferences.json"

var FolderLabel = preload("res://scenes/folder_label.tscn")

@onready var edit_menu = get_node("Window/MenuBar/EditMenu")
@onready var background_logo_sprite = get_node("BackgroundLogoSprite")

@onready var form_vbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox")
@onready var choose_folder_button = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ChooseFolderButton")
@onready var customer_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CustomerLine")
@onready var customer_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CustomerLine/CustomerLabel")
@onready var customer_option = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CustomerLine/CustomerOption")
@onready var customer_edit = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CustomerLine/CustomerEdit")
@onready var project_name_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProjectNameLine/ProjectNameLabel")
@onready var project_name_edit = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProjectNameLine/ProjectNameEdit")
@onready var production_type_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionTypeLine/ProductionTypeLabel")
@onready var production_type_option = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionTypeLine/ProductionTypeOption")

@onready var production_audio_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionAudioLine/ProductionAudioLabel")
@onready var production_audio_checkbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionAudioLine/ProductionAudioCheckBox")
@onready var music_Label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/MusicLine/MusicLabel")
@onready var music_checkbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/MusicLine/MusicCheckBox")
@onready var audio_sfx_Label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/AudioSFXLine/AudioSFXLabel")
@onready var audio_sfx_checkbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/AudioSFXLine/AudioSFXCheckBox")

@onready var preview_folder_button = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/PreGenerateFolderButton")
@onready var generate_folder_button = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/GenerateFolderButton")

@onready var summary_vbox = get_node("Window/WorkspaceHBox/SummaryContainer/SummaryVBox")
@onready var summary_label = get_node("Window/WorkspaceHBox/SummaryContainer/SummaryVBox/SummaryLabel")
@onready var summary_folders_vbox = get_node("Window/WorkspaceHBox/SummaryContainer/SummaryVBox/SummaryFoldersVBox")

var user_preferences: UserPreferences
var customer_name: String = ""
var project_name: String = ""
var production_type: ProductionType
var use_production_audio: bool = true
var use_music: bool = true
var use_audio_sfx: bool = true
var has_previewed: bool = false
var info_locked: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	user_preferences = UserPreferences.load_from_file(USER_PREF_PATH)
	update_edit_hide_logo()
	if user_preferences.has_default_path:
		build_customer_options()
	update_controls()

func generate_folders_label() -> void:
	for c in summary_folders_vbox.get_children():
		c.queue_free()
	add_new_folder("01 Preproduction")
	add_new_folder("02 Production")
	add_new_folder("03 Audio")
	if use_production_audio: add_new_folder("          Production audio")
	if use_audio_sfx: add_new_folder("          SFX")
	if use_music:
		add_new_folder("          Sound track")
		add_new_folder("                    01 Sound track temp")
		add_new_folder("                    02 Final licensed tracks")
		add_new_folder("                    03 License agreements and contracts")
	add_new_folder("04 Footage")
	add_new_folder("          A001")
	add_new_folder("05 VFX")
	add_new_folder("          Shots")
	add_new_folder("06 Assets")
	add_new_folder("          00 Drop-box")
	add_new_folder("          01 Logo and branding")
	add_new_folder("          02 Branding guidelines")
	add_new_folder("07 Working renders")
	if production_type == ProductionType.EXTERNAL:
		add_new_folder("          Offline drafts")
		add_new_folder("          Online drafts")
	else:
		add_new_folder("          Drafts")
	add_new_folder("          Process renders")
	add_new_folder("          Screenshots")
	add_new_folder("08 Final renders")
	add_new_folder("09 Working edit files")
	add_new_folder("10 DaVinci project archive")
	add_new_folder("11 Notes")
	add_new_folder("          Director notes")
	add_new_folder("          Editor notes")
	add_new_folder("          Production notes")
	add_new_folder("          PVs and transcriptions")
	add_new_folder("00 Vous etes ici - lisez-moi.txt")
	
	generate_folders_tree()

func generate_folders_tree() -> void:
	var folder_id: int = 1
	var tree = get_node("Window/WorkspaceHBox/SummaryContainer/Test/Tree")
	tree.clear()
	var root = tree.create_item()
	tree.hide_root = true
	
	# Preproduction
	var preprod_folder: TreeItem = tree.create_item(root)
	var preprod_string: String = "0" + str(folder_id) + " Preproduction"
	preprod_folder.set_text(0, preprod_string)
	folder_id += 1
	
	# Production
	var prod_folder: TreeItem = tree.create_item(root)
	var prod_string: String = "0" + str(folder_id) + " Production"
	prod_folder.set_text(0, prod_string)
	folder_id += 1
	
	# Audio
	var audio_folder: TreeItem = tree.create_item(root)
	var audio_string: String = "0" + str(folder_id) + " Audio"
	audio_folder.set_text(0, audio_string)
	if use_production_audio:
		var prod_audio_f: TreeItem = tree.create_item(audio_folder)
		prod_audio_f.set_text(0, "Production audio")
	if use_music:
		var music_f: TreeItem = tree.create_item(audio_folder)
		music_f.set_text(0, "Sound track")
		var sub_music_f: TreeItem = tree.create_item(music_f)
		sub_music_f.set_text(0, "01 Sound track temp")
		sub_music_f = tree.create_item(music_f)
		sub_music_f.set_text(0, "02 Final licensed tracks")
		sub_music_f = tree.create_item(music_f)
		sub_music_f.set_text(0, "03 License agreements and contracts")
	if use_audio_sfx:
		var audio_sfx_f: TreeItem = tree.create_item(audio_folder)
		audio_sfx_f.set_text(0, "SFX")
	folder_id += 1
	
	# Footage
	var foot_folder: TreeItem = tree.create_item(root)
	var foot_string: String = "0" + str(folder_id) + " Footage"
	foot_folder.set_text(0, foot_string)
	folder_id += 1
	
	# VFX
	var vfx_folder: TreeItem = tree.create_item(root)
	var vfx_string: String = "0" + str(folder_id) + " VFX"
	vfx_folder.set_text(0, vfx_string)
	folder_id += 1
	
	# Assets
	var assets_folder: TreeItem = tree.create_item(root)
	var assets_string: String = "0" + str(folder_id) + " Assets"
	assets_folder.set_text(0, assets_string)
	folder_id += 1
	
	# Working renders
	var w_renders_folder: TreeItem = tree.create_item(root)
	var w_renders_string: String = "0" + str(folder_id) + " Working renders"
	w_renders_folder.set_text(0, w_renders_string)
	var sub_w_renders_folder: TreeItem# = tree.create_item(w_renders_folder)
	var sub_w_renders_string: String# = "Offline drafts"
	if production_type == ProductionType.EXTERNAL:
		sub_w_renders_folder = tree.create_item(w_renders_folder)
		sub_w_renders_folder.set_text(0, "Offline drafts")
		sub_w_renders_folder = tree.create_item(w_renders_folder)
		sub_w_renders_folder.set_text(0, "Online drafts")
	elif production_type == ProductionType.INTERNAL:
		sub_w_renders_folder = tree.create_item(w_renders_folder)
		sub_w_renders_folder.set_text(0, "Drafts")
	else:
		PrintUtility.print_error("Unknown production type : " + str(production_type))
	
	sub_w_renders_folder = tree.create_item(w_renders_folder)
	sub_w_renders_folder.set_text(0, "Process renders")
	sub_w_renders_folder = tree.create_item(w_renders_folder)
	sub_w_renders_folder.set_text(0, "Screenshots")
	folder_id += 1
	
	# Final renders
	var f_renders_folder: TreeItem = tree.create_item(root)
	var f_renders_string: String = "0" + str(folder_id) + " Final renders"
	f_renders_folder.set_text(0, f_renders_string)
	folder_id += 1
	
	# Working edit files
	var w_edit_folder: TreeItem = tree.create_item(root)
	var w_edit_string: String = "0" + str(folder_id) + " Working edit files"
	w_edit_folder.set_text(0, w_edit_string)
	folder_id += 1
	
	# DaVinci project archive
	var dv_archive_folder: TreeItem = tree.create_item(root)
	var dv_archive_string: String = "0" + str(folder_id) + " DaVinci project archive" if folder_id < 10 else str(folder_id) + " DaVinci project archive"
	dv_archive_folder.set_text(0, dv_archive_string)
	folder_id += 1
	
	# Notes
	var notes_folder: TreeItem = tree.create_item(root)
	var notes_string: String = "0" + str(folder_id) + " Notes" if folder_id < 10 else str(folder_id) + " Notes"
	notes_folder.set_text(0, notes_string)
	var sub_notes_folder: TreeItem = tree.create_item(notes_folder)
	sub_notes_folder.set_text(0, "Director notes")
	sub_notes_folder = tree.create_item(notes_folder)
	sub_notes_folder.set_text(0, "Editor notes")
	sub_notes_folder = tree.create_item(notes_folder)
	sub_notes_folder.set_text(0, "Production notes")
	sub_notes_folder = tree.create_item(notes_folder)
	sub_notes_folder.set_text(0, "PV and transcriptions")
	folder_id += 1
	
	# Read-me
	var rm_folder: TreeItem = tree.create_item(root)
	var rm_string: String = "00 Vous etes ici - lisez-moi.txt"
	rm_folder.set_text(0, rm_string)
	folder_id += 1

func add_new_folder(text: String) -> void:
	var temp_label = FolderLabel.instantiate()
	temp_label.text = text
	summary_folders_vbox.add_child(temp_label)

func update_controls() -> void: # Updating form controls depending how much user has filled it
	
	var customer_editable = user_preferences.has_default_path and not info_locked
	var project_name_editable = customer_editable and customer_name != ""
	var production_type_editable = project_name_editable and project_name != ""
	var secondary_options_editable = production_type_editable and production_type_option.selected != -1
	
	# Choose folder button
	choose_folder_button.disabled = info_locked
	
	# Customer name
	customer_label.disable(not customer_editable)
	customer_option.disabled = not customer_editable
	customer_edit.editable = customer_editable
	customer_edit.visible = customer_option.selected == 0
	
	# Project name
	project_name_label.disable(not project_name_editable)
	project_name_edit.editable = project_name_editable
	if project_name_editable and project_name != "":
		if path_has_conflict():
			project_name_edit.modulate = Color(1,0.5,0,1)
		else:
			project_name_edit.modulate = Color(1,1,1,1)
	
	# Production type
	production_type_label.disable(not production_type_editable)
	production_type_option.disabled = not production_type_editable
	
	# Audio checkboxes
	production_audio_label.disable(not secondary_options_editable)
	production_audio_checkbox.disabled = not secondary_options_editable
	music_Label.disable(not secondary_options_editable)
	music_checkbox.disabled = not secondary_options_editable
	audio_sfx_Label.disable(not secondary_options_editable)
	audio_sfx_checkbox.disabled = not secondary_options_editable
	
	# Buttons
	preview_folder_button.disabled = not (user_preferences.has_default_path and customer_name != "" and project_name != "" and production_type_option.selected != -1 and not path_has_conflict())
	generate_folder_button.disabled = not (user_preferences.has_default_path and customer_name != "" and project_name != "" and production_type_option.selected != -1 and info_locked)
	
	# Tree
	get_node("Window/WorkspaceHBox/SummaryContainer/Test/Tree").mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE if not info_locked else MouseFilter.MOUSE_FILTER_STOP
	get_node("Window/WorkspaceHBox/SummaryContainer/Test/Tree").modulate = Color(1,1,1,1) if info_locked else Color(1,1,1,0.5)

func path_has_conflict() -> bool:
	return DirAccess.dir_exists_absolute(user_preferences.default_path + "/" + customer_name + "/" + project_name)

func build_customer_options() -> void:
	customer_option.clear()
	customer_option.add_item("<Nouveau client>")
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
	
	if customer_name != "" and project_name != "":
		summary_label.text += "\n" + "Chemin du projet : " + user_preferences.default_path + "/" + customer_name + "/" + project_name
	
	if production_type_option.selected > -1:
		if production_type == ProductionType.EXTERNAL:
			summary_label.text += "\n" + "Client externe"
		else:
			summary_label.text += "\n" + "Projet interne"
	
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
	build_customer_options()
	update_controls()

func _on_file_dialog_canceled() -> void:
	PrintUtility.print_info("User cancelled folder choice")

func _on_pre_generate_folder_button_pressed() -> void:
	info_locked = not info_locked
	
	if info_locked: PrintUtility.print_info("Start previewing folders ...")
	else: PrintUtility.print_info("Cancelled previewing folders")
	
	if info_locked:
		# Compute delay per element to last in total 2 seconds
		for i in range(summary_folders_vbox.get_child_count()):
			summary_folders_vbox.get_child(i).delay = i * (2.0 / summary_folders_vbox.get_child_count())
		# Activate all elements
		for e in summary_folders_vbox.get_children():
			e.activate()
		has_previewed = true
		preview_folder_button.text = "Annuler"
	else:
		for c in summary_folders_vbox.get_children():
			c.desactivate()
		preview_folder_button.text = "Verrouiller et prévisualiser"
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

# MenuBar signals =================================================================================

func _on_file_menu_id_pressed(id: int) -> void:
	match id:
		0:
			PrintUtility.print_info("Quitting the software ...")
			get_tree().quit()
		1:
			PrintUtility.print_info("Starting new project ...")
			customer_name = ""
			customer_option.selected = 0
			customer_edit.text = ""
			project_name = ""
			project_name_edit.text = ""
			project_name_edit.modulate = Color(1,1,1,1)
			production_type_option.selected = -1
			use_production_audio = true
			production_audio_checkbox.button_pressed = true
			use_music = true
			music_checkbox.button_pressed = true
			use_audio_sfx = true
			audio_sfx_checkbox.button_pressed = true
			info_locked = false
			for c in summary_folders_vbox.get_children():
				c.desactivate()
			preview_folder_button.text = "Verrouiller et prévisualiser"
			update_controls()
			update_summary()
		_:
			PrintUtility.print_info("Unkown file menu option")

func update_edit_hide_logo() -> void:
	edit_menu.set_item_checked(edit_menu.get_item_index(1), user_preferences.hide_dry_kats_logo)
	background_logo_sprite.visible = not user_preferences.hide_dry_kats_logo

func _on_edit_menu_id_pressed(id: int) -> void:
	match id:
		0:
			PrintUtility.print_info("Reset preferences")
			user_preferences.reset_user_preferences(USER_PREF_PATH)
			project_name = ""
			customer_name = ""
			update_edit_hide_logo()
			update_controls()
			update_summary()
		1:
			user_preferences.hide_dry_kats_logo = not user_preferences.hide_dry_kats_logo
			user_preferences.save_to_file(USER_PREF_PATH)
			update_edit_hide_logo()
		_:
			PrintUtility.print_info("Unkown edition menu option")

func _on_production_audio_check_box_toggled(toggled_on: bool) -> void:
	use_production_audio = toggled_on
	generate_folders_label()

func _on_music_check_box_toggled(toggled_on: bool) -> void:
	use_music = toggled_on
	generate_folders_label()

func _on_audio_sfx_check_box_toggled(toggled_on: bool) -> void:
	use_audio_sfx = toggled_on
	generate_folders_label()
