extends Control

enum ProductionType {
	EXTERNAL,
	INTERNAL
}

const USER_PREF_PATH: String = "user://user_preferences.json"

const TREE_DEFAULT: Color = Color(0.7, 0.7, 0.7, 1)
const TREE_HIGHLIGHTED: Color = Color(0.8, 0.4, 0, 1)

@export var checked_color: Color = Color(0,1,0)
@export var warning_color: Color = Color(1,0.5,0)

#const CURRENT_VERSION: String = "0.1.1"

var empty_texture: Texture2D = preload("res://resources/icons/empty_16.png")
var error_texture: Texture2D = preload("res://resources/icons/cancel_16.png")
var checked_texture: Texture2D = preload("res://resources/icons/checked_16.png")
var information_texture: Texture2D = preload("res://resources/icons/information_16.png")

@onready var tutorial = get_node("Tutorial")

@onready var edit_menu = get_node("Window/MenuBar/EditMenu")
@onready var background_logo_sprite = get_node("BackgroundLogoSprite")
@onready var preferences_dialog = get_node("PreferencesDialog")

@onready var form_vbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox")

@onready var general_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/GeneralTitleLabel")

@onready var choose_folder_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ChooseFolderLine")
@onready var choose_folder_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ChooseFolderLine/ChooseFolderLabel")
@onready var choose_folder_button = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ChooseFolderLine/ChooseFolderButton")
@onready var choose_folder_result = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ChooseFolderLine/ChooseFolderResult")
@onready var customer_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CustomerLine")
@onready var customer_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CustomerLine/CustomerLabel")
@onready var customer_option = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CustomerLine/CustomerOption")
@onready var customer_edit = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CustomerLine/CustomerEdit")
@onready var project_name_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProjectNameLine")
@onready var project_name_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProjectNameLine/ProjectNameLabel")
@onready var project_name_edit = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProjectNameLine/ProjectNameEdit")
@onready var production_type_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionTypeLine")
@onready var production_type_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionTypeLine/ProductionTypeLabel")
@onready var production_type_option = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionTypeLine/ProductionTypeOption")
@onready var editor_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/EditorLine")
@onready var editor_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/EditorLine/EditorLabel")
@onready var editor_option = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/EditorLine/EditorOption")
@onready var editor_edit = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/EditorLine/EditorEdit")

@onready var audio_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/AudioTitleLabel")

@onready var production_audio_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionAudioLine")
@onready var production_audio_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionAudioLine/ProductionAudioLabel")
@onready var production_audio_checkbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/ProductionAudioLine/ProductionAudioCheckBox")
@onready var music_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/MusicLine")
@onready var music_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/MusicLine/MusicLabel")
@onready var music_checkbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/MusicLine/MusicCheckBox")
@onready var audio_sfx_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/AudioSFXLine")
@onready var audio_sfx_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/AudioSFXLine/AudioSFXLabel")
@onready var audio_sfx_checkbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/AudioSFXLine/AudioSFXCheckBox")

@onready var video_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/VideoTitleLabel")

@onready var daycount_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/DayCountLine")
@onready var daycount_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/DayCountLine/DayCountLabel")
@onready var daycount_spin = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/DayCountLine/DayCountSpin")
@onready var cameracount_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CameraCountLine")
@onready var cameracount_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CameraCountLine/CameraCountLabel")
@onready var cameracount_spin = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/CameraCountLine/CameraCountSpin")
@onready var vfx_line = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/VFXLine")
@onready var vfx_label = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/VFXLine/VFXLabel")
@onready var vfx_checkbox = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/VFXLine/VFXCheckBox")

@onready var preview_folder_button = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/PreGenerateFolderButton")
@onready var generate_folder_button = get_node("Window/WorkspaceHBox/FormContainer/FormVBox/GenerateFolderButton")

@onready var summary_vbox = get_node("Window/WorkspaceHBox/SummaryContainer/SummaryVBox")
@onready var summary_label = get_node("Window/WorkspaceHBox/SummaryContainer/SummaryVBox/SummaryLabel")
@onready var summary_folders_vbox = get_node("Window/WorkspaceHBox/SummaryContainer/SummaryVBox/SummaryFoldersVBox")

@onready var folder_tree = get_node("Window/WorkspaceHBox/SummaryContainer/Test/Tree")

@onready var version_label = get_node("VersionLabel")

var user_preferences: UserPreferences
var customer_name: String = ""
var project_name: String = ""
var production_type: ProductionType
var editor_name: String = ""

var daycount: int = 1
var cameracount: int = 1
var use_vfx: bool = true

var use_production_audio: bool = true
var use_music: bool = true
var use_audio_sfx: bool = true
var has_previewed: bool = false
var info_locked: bool = false

var control_hovered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	version_label.set_text("Version " + ProjectSettings.get_setting("application/config/version"))
	user_preferences = UserPreferences.load_from_file(USER_PREF_PATH)
	tutorial.tutorial_ended.connect(_on_tutorial_ended)
	update_tutorial_screen()
	update_edit_hide_logo()
	update_edit_show_highlights()
	if user_preferences.has_default_path:
		build_customer_options()
	update_controls()
	update_preferences_dialog()
	get_node("FileDialog").ok_button_text = "Sélectionner le dossier"

func update_preferences_dialog() -> void:
	var label = get_node("PreferencesDialog/PreferencesLabel")
	label.text = "Chemin du dossier : " + user_preferences.default_path
	label.text += "\nA un chemin : " + str(user_preferences.has_default_path)
	label.text += "\nMonteurs : " + str(user_preferences.editors)
	label.text += "\nClients : " + str(user_preferences.customers)
	label.text += "\nCacher logo : " + str(user_preferences.hide_logo)
	label.text += "\nAfficher surlignage : " + str(user_preferences.show_highlights)
	label.text += "\nA vu le tutoriel : " + str(user_preferences.has_seen_tutorial)

func _on_tutorial_ended() -> void:
	user_preferences.has_seen_tutorial = true
	user_preferences.save_to_file(USER_PREF_PATH)
	update_tutorial_screen()

func update_tutorial_screen() -> void:
	tutorial.reset_tutorial()
	tutorial.visible = not user_preferences.has_seen_tutorial

func generate_folders_tree() -> void:
	var folder_id: int = 1
	var tree = get_node("Window/WorkspaceHBox/SummaryContainer/Test/Tree")
	tree.clear()
	var root = tree.create_item()
	root.set_text(0, user_preferences.default_path + customer_name + "/" + project_name)
	#tree.hide_root = true
	
	# Preproduction
	var preprod_folder: TreeItem = tree.create_item(root)
	var preprod_string: String = "0" + str(folder_id) + " Preproduction"
	preprod_folder.set_text(0, preprod_string)
	preprod_folder.set_tooltip_text(0, "Dossier préproduction : recherche, direction artistique, budget, casting, ...")
	folder_id += 1
	
	# Production
	var prod_folder: TreeItem = tree.create_item(root)
	var prod_string: String = "0" + str(folder_id) + " Production"
	prod_folder.set_text(0, prod_string)
	prod_folder.set_tooltip_text(0, "Dossier production : script, plan de tournage, débouillement, horaires, ...")
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
	for c in range(cameracount):
		for d in range(daycount):
			var tmp_f: TreeItem = tree.create_item(foot_folder)
			tmp_f.set_text(0, char(c + 65) + daycount_int_to_string(d + 1))
	folder_id += 1
	
	# VFX
	if use_vfx:
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

func update_hovering() -> void:
	if user_preferences.has_default_path and not info_locked and customer_name != "" and project_name != "" and production_type_option.selected != -1 and user_preferences.show_highlights:
		reset_tree_highlights()
		if control_hovered == daycount_line:
			var tmp_tree_item: TreeItem = folder_tree.get_root().get_first_child()
			while tmp_tree_item != null:
				check_tree_item_for_daycount(tmp_tree_item)
				tmp_tree_item = tmp_tree_item.get_next()
		elif control_hovered == cameracount_line:
			var tmp_tree_item: TreeItem = folder_tree.get_root().get_first_child()
			while tmp_tree_item != null:
				check_tree_item_for_cameracount(tmp_tree_item)
				tmp_tree_item = tmp_tree_item.get_next()
		elif control_hovered == vfx_line:
			var tmp_tree_item: TreeItem = folder_tree.get_root().get_first_child()
			while tmp_tree_item != null:
				check_tree_item_for_vfx(tmp_tree_item)
				tmp_tree_item = tmp_tree_item.get_next()
		elif control_hovered == production_audio_line:
			var tmp_tree_item: TreeItem = folder_tree.get_root().get_first_child()
			while tmp_tree_item != null:
				check_tree_item_for_production_audio(tmp_tree_item)
				tmp_tree_item = tmp_tree_item.get_next()
		elif control_hovered == music_line:
			var tmp_tree_item: TreeItem = folder_tree.get_root().get_first_child()
			while tmp_tree_item != null:
				check_tree_item_for_music(tmp_tree_item)
				tmp_tree_item = tmp_tree_item.get_next()
		elif control_hovered == audio_sfx_line:
			var tmp_tree_item: TreeItem = folder_tree.get_root().get_first_child()
			while tmp_tree_item != null:
				check_tree_item_for_audio_sfx(tmp_tree_item)
				tmp_tree_item = tmp_tree_item.get_next()

func reset_tree_highlights() -> void:
	if folder_tree.get_root() != null:
		if folder_tree.get_root().get_child_count() > 0:
			#var tmp_tree_item: TreeItem = folder_tree.get_root().get_first_child()
			if folder_tree.get_root().get_child_count() > 0:
				for c in folder_tree.get_root().get_children():
					c.set_custom_color(0, TREE_DEFAULT)
					if c.get_child_count() > 0:
						for cc in c.get_children():
							cc.set_custom_color(0, TREE_DEFAULT)
							if cc.get_child_count() > 0:
								for ccc in cc.get_children():
									ccc.set_custom_color(0, TREE_DEFAULT)
									if ccc.get_child_count() > 0:
										for cccc in ccc.get_children():
											cccc.set_custom_color(0, TREE_DEFAULT)

func check_tree_item_for_daycount(tree_item: TreeItem) -> void:
	if tree_item.get_text(0).find("Footage") != -1:
		tree_item.set_custom_color(0, TREE_HIGHLIGHTED)
		if tree_item.get_child_count() > 0:
			for c in tree_item.get_children():
				c.set_custom_color(0, TREE_HIGHLIGHTED)

func check_tree_item_for_cameracount(tree_item: TreeItem) -> void:
	if tree_item.get_text(0).find("Footage") != -1:
		tree_item.set_custom_color(0, TREE_HIGHLIGHTED)
		if tree_item.get_child_count() > 0:
			for c in tree_item.get_children():
				c.set_custom_color(0, TREE_HIGHLIGHTED)

func check_tree_item_for_vfx(tree_item: TreeItem) -> void:
	if tree_item.get_text(0).find("VFX") != -1:
		tree_item.set_custom_color(0, TREE_HIGHLIGHTED)
		if tree_item.get_child_count() > 0:
			for c in tree_item.get_children():
				c.set_custom_color(0, TREE_HIGHLIGHTED)

func check_tree_item_for_production_audio(tree_item: TreeItem) -> void:
	if tree_item.get_text(0).find("Audio") != -1:
		tree_item.set_custom_color(0, TREE_HIGHLIGHTED)
		if tree_item.get_child_count() > 0:
			for c in tree_item.get_children():
				if c.get_text(0).find("Production audio") != -1:
					c.set_custom_color(0, TREE_HIGHLIGHTED)

func check_tree_item_for_music(tree_item: TreeItem) -> void:
	if tree_item.get_text(0).find("Audio") != -1:
		tree_item.set_custom_color(0, TREE_HIGHLIGHTED)
		if tree_item.get_child_count() > 0:
			for c in tree_item.get_children():
				if c.get_text(0).find("Sound track") != -1:
					c.set_custom_color(0, TREE_HIGHLIGHTED)
					if c.get_child_count() > 0:
						for cc in c.get_children():
							cc.set_custom_color(0, TREE_HIGHLIGHTED)

func check_tree_item_for_audio_sfx(tree_item: TreeItem) -> void:
	if tree_item.get_text(0).find("Audio") != -1:
		tree_item.set_custom_color(0, TREE_HIGHLIGHTED)
		if tree_item.get_child_count() > 0:
			for c in tree_item.get_children():
				if c.get_text(0).find("SFX") != -1:
					c.set_custom_color(0, TREE_HIGHLIGHTED)

func update_controls() -> void: # Updating form controls depending how much user has filled it
	
	var customer_editable = user_preferences.has_default_path and not info_locked
	var project_name_editable = customer_editable and customer_name != ""
	var production_type_editable = project_name_editable and project_name != ""
	var editor_editable = production_type_editable and production_type_option.selected != -1
	var secondary_options_editable = editor_editable and editor_name != ""
	
	# Choose folder button
	general_label.disable(info_locked)
	choose_folder_button.disabled = info_locked
	choose_folder_label.disable(info_locked)
	choose_folder_result.text = user_preferences.default_path
	choose_folder_result.tooltip_text = user_preferences.default_path
	choose_folder_line.get_node("LineIcon").texture = checked_texture if customer_editable else empty_texture
	choose_folder_line.get_node("LineIcon").modulate = checked_color
	
	# Customer name
	customer_label.disable(not customer_editable)
	customer_option.disabled = not customer_editable
	customer_edit.editable = customer_editable and customer_option.selected == 0
	customer_line.get_node("LineIcon").texture = checked_texture if project_name_editable else empty_texture
	customer_line.get_node("LineIcon").modulate = checked_color
	
	# Project name
	project_name_label.disable(not project_name_editable)
	project_name_edit.editable = project_name_editable
	if project_name_editable and project_name != "":
		if path_has_conflict():
			project_name_edit.modulate = Color(1,0.5,0,1)
			project_name_line.get_node("LineIcon").texture = error_texture
			project_name_line.get_node("LineIcon").modulate = warning_color
		else:
			project_name_edit.modulate = Color(1,1,1,1)
			project_name_line.get_node("LineIcon").texture = checked_texture
			project_name_line.get_node("LineIcon").modulate = checked_color
	if not production_type_editable:
		project_name_line.get_node("LineIcon").texture = empty_texture
	
	# Production type
	production_type_label.disable(not production_type_editable)
	production_type_option.disabled = not production_type_editable
	production_type_line.get_node("LineIcon").texture = checked_texture if editor_editable else empty_texture
	production_type_line.get_node("LineIcon").modulate = checked_color
	
	# Editor name
	editor_label.disable(not editor_editable)
	editor_option.disabled = not editor_editable
	editor_edit.editable = editor_editable and editor_option.selected == 0
	editor_line.get_node("LineIcon").texture = checked_texture if secondary_options_editable else empty_texture
	editor_line.get_node("LineIcon").modulate = checked_color
	
	# Audio checkboxes
	audio_label.disable(not secondary_options_editable)
	production_audio_label.disable(not secondary_options_editable)
	production_audio_checkbox.disabled = not secondary_options_editable
	music_label.disable(not secondary_options_editable)
	music_checkbox.disabled = not secondary_options_editable
	audio_sfx_label.disable(not secondary_options_editable)
	audio_sfx_checkbox.disabled = not secondary_options_editable
	
	# Video
	video_label.disable(not secondary_options_editable)
	daycount_label.disable(not secondary_options_editable)
	daycount_spin.editable = secondary_options_editable
	cameracount_label.disable(not secondary_options_editable)
	cameracount_spin.editable = secondary_options_editable
	vfx_label.disable(not secondary_options_editable)
	vfx_checkbox.disabled = not secondary_options_editable
	
	# Buttons
	preview_folder_button.disabled = not (user_preferences.has_default_path and customer_name != "" and project_name != "" and production_type_option.selected != -1 and editor_name != "" and not path_has_conflict())
	generate_folder_button.disabled = not (user_preferences.has_default_path and customer_name != "" and project_name != "" and production_type_option.selected != -1 and editor_name != "" and info_locked)
	
	# Tree
	if customer_name != "" and project_name != "":
		generate_folders_tree()
	else:
		get_node("Window/WorkspaceHBox/SummaryContainer/Test/Tree").clear()

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
			#print("No project")
			pass
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
	PrintUtility.print_WIP("Start generating folders ...")
	if user_preferences.editors.find(editor_name, 0) == -1:
		user_preferences.editors.append(editor_name)
		user_preferences.save_to_file(USER_PREF_PATH)
	if user_preferences.customers.find(customer_name, 0) == -1:
		user_preferences.customers.append(customer_name)
		user_preferences.save_to_file(USER_PREF_PATH)
	#var result = DirAccess.make_dir_absolute(user_preferences.default_path + "/" + project_name)
	#match result:
		#0:
			#PrintUtility.print_info("Success")
		#32:
			#PrintUtility.print_error("Folder already exists")
		#_:
			#PrintUtility.print_error("Unkown error : " + str(result))

func _on_customer_option_item_selected(index: int) -> void:
	if index == 0:
		customer_name = customer_edit.text
	else:
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

func _on_editor_option_item_selected(index: int) -> void:
	if index == 0:
		editor_name = editor_edit.text
	else:
		editor_name = editor_option.get_item_text(index)
	update_controls()
	update_summary()

func _on_editor_edit_text_changed(new_text: String) -> void:
	editor_name = new_text
	update_controls()
	update_summary()

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
			daycount = 1
			daycount_spin.value = 1
			cameracount = 1
			cameracount_spin.value = 1
			use_vfx = true
			vfx_checkbox.button_pressed = true
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
	edit_menu.set_item_checked(edit_menu.get_item_index(1), user_preferences.hide_logo)
	background_logo_sprite.visible = not user_preferences.hide_logo

func update_edit_show_highlights() -> void:
	edit_menu.set_item_checked(edit_menu.get_item_index(2), user_preferences.show_highlights)
	if not user_preferences.show_highlights:
		reset_tree_highlights()

func _on_edit_menu_id_pressed(id: int) -> void:
	match id:
		0: # Reset preferences
			PrintUtility.print_info("Reset preferences")
			user_preferences.reset_user_preferences(USER_PREF_PATH)
			project_name = ""
			customer_name = ""
			update_edit_hide_logo()
			update_edit_show_highlights()
			update_controls()
			update_summary()
		1: # Hide logo
			user_preferences.hide_logo = not user_preferences.hide_logo
			user_preferences.save_to_file(USER_PREF_PATH)
			update_edit_hide_logo()
		2: # Show highlight
			user_preferences.show_highlights = not user_preferences.show_highlights
			user_preferences.save_to_file(USER_PREF_PATH)
			update_edit_show_highlights()
		4: # Show preferences summary
			update_preferences_dialog()
			preferences_dialog.visible = true
		5: # Purge editors
			user_preferences.editors = []
			user_preferences.save_to_file(USER_PREF_PATH)
		6: # Purge customers
			user_preferences.customers = []
			user_preferences.save_to_file(USER_PREF_PATH)
		_:
			PrintUtility.print_info("Unkown edition menu option")

func _on_help_menu_id_pressed(id: int) -> void:
	match id:
		0: # Help-me
			pass
		1: # Rewatch tutorial
			user_preferences.has_seen_tutorial = false
			user_preferences.save_to_file(USER_PREF_PATH)
			update_tutorial_screen()

func update_line_icon(line, value: bool) -> void:
	line.get_node("LineIcon").texture = empty_texture if value else information_texture
	line.get_node("LineIcon").tooltip_text = "" if value else "Cette valeur a été modifiée"

func _on_production_audio_check_box_toggled(toggled_on: bool) -> void:
	use_production_audio = toggled_on
	update_line_icon(production_audio_line, toggled_on)
	update_controls()
	_on_production_audio_line_mouse_entered()

func _on_production_audio_line_mouse_entered() -> void:
	control_hovered = production_audio_line
	update_hovering()

func _on_music_check_box_toggled(toggled_on: bool) -> void:
	use_music = toggled_on
	update_line_icon(music_line, toggled_on)
	update_controls()
	_on_music_line_mouse_entered()

func _on_music_line_mouse_entered() -> void:
	control_hovered = music_line
	update_hovering()

func _on_audio_sfx_check_box_toggled(toggled_on: bool) -> void:
	use_audio_sfx = toggled_on
	update_line_icon(audio_sfx_line, toggled_on)
	update_controls()
	_on_audio_sfx_line_mouse_entered()

func _on_audio_sfx_line_mouse_entered() -> void:
	control_hovered = audio_sfx_line
	update_hovering()

func _on_day_count_spin_value_changed(value: int) -> void:
	daycount = value
	update_line_icon(daycount_line, value == 1)
	update_controls()
	_on_day_count_line_mouse_entered()

func _on_day_count_line_mouse_entered() -> void:
	control_hovered = daycount_line
	update_hovering()

func _on_camera_count_spin_value_changed(value: int) -> void:
	cameracount = value
	update_line_icon(cameracount_line, value == 1)
	update_controls()
	_on_camera_count_line_mouse_entered()

func _on_camera_count_line_mouse_entered() -> void:
	control_hovered = cameracount_line
	update_hovering()

func _on_vfx_check_box_toggled(toggled_on: bool) -> void:
	use_vfx = toggled_on
	update_line_icon(vfx_line, toggled_on)
	update_controls()
	_on_vfx_line_mouse_entered()

func _on_vfx_line_mouse_entered() -> void:
	control_hovered = vfx_line
	update_hovering()

# =================================================================================================

func daycount_int_to_string(value: int) -> String:
	var tmp_string: String = ""
	if value < 10:
		tmp_string += "0"
	if value < 100:
		tmp_string += "0"
	tmp_string += str(value)
	return tmp_string
