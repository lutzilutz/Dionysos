extends HBoxContainer

const TREE_DEFAULT: Color = Color(0.7, 0.7, 0.7, 1)
const TREE_HIGHLIGHTED: Color = Color(0.8, 0.4, 0, 1)

var main_scene

@onready var generation_completed_dialog = get_node("GenerationCompletedDialog")
@onready var form_vbox = get_node("FormContainer/FormVBox")

@onready var general_label = form_vbox.get_node("GeneralTitleLabel")

@onready var choose_folder_line = form_vbox.get_node("ChooseFolderLine")
@onready var choose_folder_label = choose_folder_line.get_node("ChooseFolderLabel")
@onready var choose_folder_button = choose_folder_line.get_node("ChooseFolderButton")
@onready var choose_folder_result = choose_folder_line.get_node("ChooseFolderResult")
@onready var customer_line = form_vbox.get_node("CustomerLine")
@onready var customer_label = customer_line.get_node("CustomerLabel")
@onready var customer_option = customer_line.get_node("CustomerOption")
@onready var customer_edit = customer_line.get_node("CustomerEdit")
@onready var project_name_line = form_vbox.get_node("ProjectNameLine")
@onready var project_name_label = project_name_line.get_node("ProjectNameLabel")
@onready var project_name_edit = project_name_line.get_node("ProjectNameEdit")
@onready var production_type_line = form_vbox.get_node("ProductionTypeLine")
@onready var production_type_label = production_type_line.get_node("ProductionTypeLabel")
@onready var production_type_option = production_type_line.get_node("ProductionTypeOption")
@onready var editor_line = form_vbox.get_node("EditorLine")
@onready var editor_label = editor_line.get_node("EditorLabel")
@onready var editor_option = editor_line.get_node("EditorOption")
@onready var editor_edit = editor_line.get_node("EditorEdit")
@onready var include_contact_line = form_vbox.get_node("IncludeContactLine")
@onready var include_contact_label = include_contact_line.get_node("IncludeContactLabel")
@onready var include_contact_checkbox = include_contact_line.get_node("IncludeContactCheckbox")

@onready var audio_label = form_vbox.get_node("AudioTitleLabel")

@onready var production_audio_line = form_vbox.get_node("ProductionAudioLine")
@onready var production_audio_label = production_audio_line.get_node("ProductionAudioLabel")
@onready var production_audio_checkbox = production_audio_line.get_node("ProductionAudioCheckBox")
@onready var music_line = form_vbox.get_node("MusicLine")
@onready var music_label = music_line.get_node("MusicLabel")
@onready var music_checkbox = music_line.get_node("MusicCheckBox")
@onready var audio_sfx_line = form_vbox.get_node("AudioSFXLine")
@onready var audio_sfx_label = audio_sfx_line.get_node("AudioSFXLabel")
@onready var audio_sfx_checkbox = audio_sfx_line.get_node("AudioSFXCheckBox")

@onready var video_label = form_vbox.get_node("VideoTitleLabel")

@onready var daycount_line = form_vbox.get_node("DayCountLine")
@onready var daycount_label = daycount_line.get_node("DayCountLabel")
@onready var daycount_spin = daycount_line.get_node("DayCountSpin")
@onready var cameracount_line = form_vbox.get_node("CameraCountLine")
@onready var cameracount_label = cameracount_line.get_node("CameraCountLabel")
@onready var cameracount_spin = cameracount_line.get_node("CameraCountSpin")
@onready var vfx_line = form_vbox.get_node("VFXLine")
@onready var vfx_label = vfx_line.get_node("VFXLabel")
@onready var vfx_checkbox = vfx_line.get_node("VFXCheckBox")

@onready var preview_folder_button = form_vbox.get_node("PreGenerateFolderButton")
@onready var generate_folder_button = form_vbox.get_node("GenerateFolderButton")

@onready var summary_title = get_node("SummaryContainer/Summary/SummaryTitleLabel")
@onready var summary_body = get_node("SummaryContainer/Summary/SummaryBodyLabel")
@onready var folder_tree: Tree = get_node("SummaryContainer/Summary/Tree")

# Project informations
var customer_name: String = ""
var project_name: String = ""
var production_type: DataManager.ProductionType
var editor_name: String = ""
var use_contact: bool = true
var daycount: int = 1
var cameracount: int = 1
var use_vfx: bool = true
var use_production_audio: bool = true
var use_music: bool = true
var use_audio_sfx: bool = true
var has_previewed: bool = false
var info_locked: bool = false

# Other
var readme: ReadMe
var control_hovered
var generation_has_issue: int = 0
var generation_issues: String = ""

func _ready() -> void:
	pass

func init(scene) -> void:
	main_scene = scene
	readme = ReadMe.new()
	readme.main_scene = scene
	if main_scene.user_preferences.has_default_path:
		build_customer_options()
	build_editor_options()
	update_controls()

func generate_folders_tree() -> void:
	var folder_id: int = 1
	var tree = folder_tree
	tree.clear()
	var root = tree.create_item()
	root.set_text(0, main_scene.user_preferences.default_path + "/" + customer_name + "/" + project_name)
	
	# Preproduction
	var preprod_folder: TreeItem = tree.create_item(root)
	var preprod_string: String = "0" + str(folder_id) + " Preproduction"
	preprod_folder.set_text(0, preprod_string)
	preprod_folder.set_tooltip_text(0, "Contient tous les documents liés à la préproduction : dossiers, direction artistique, casting, lieux de tournage, storyboard ...")
	folder_id += 1
	
	# Production
	var prod_folder: TreeItem = tree.create_item(root)
	var prod_string: String = "0" + str(folder_id) + " Production"
	prod_folder.set_text(0, prod_string)
	prod_folder.set_tooltip_text(0, "Contient tous les documents liés à la production : script, shotlist, plan de tournage, ...")
	folder_id += 1
	
	# Audio
	var audio_folder: TreeItem = tree.create_item(root)
	var audio_string: String = "0" + str(folder_id) + " Audio"
	audio_folder.set_text(0, audio_string)
	audio_folder.set_tooltip_text(0, "Contient l'ensemble des fichiers audio utilisés dans le projet")
	if use_production_audio:
		var prod_audio_f: TreeItem = tree.create_item(audio_folder)
		prod_audio_f.set_text(0, "Production audio")
		prod_audio_f.set_tooltip_text(0, "Contient tous les fichiers audio produits lors de la production")
	if use_music:
		var music_f: TreeItem = tree.create_item(audio_folder)
		music_f.set_text(0, "Sound track")
		music_f.set_tooltip_text(0, "Contient les musiques.")
		var sub_music_f: TreeItem = tree.create_item(music_f)
		sub_music_f.set_text(0, "01 Sound track temp")
		sub_music_f.set_tooltip_text(0, "Contient les musiques temporaires/de travail")
		sub_music_f = tree.create_item(music_f)
		sub_music_f.set_text(0, "02 Final licensed tracks")
		sub_music_f.set_tooltip_text(0, "Contient les musiques finales, avec license en ordre ou libre de droit")
		sub_music_f = tree.create_item(music_f)
		sub_music_f.set_text(0, "03 License agreements and contracts")
		sub_music_f.set_tooltip_text(0, "Pour les musiques sous license, contient les différents documents attestants de nos droits")
	if use_audio_sfx:
		var audio_sfx_f: TreeItem = tree.create_item(audio_folder)
		audio_sfx_f.set_text(0, "SFX")
		audio_sfx_f.set_tooltip_text(0, "Contient les effets audio")
	folder_id += 1
	
	# Footage
	var foot_folder: TreeItem = tree.create_item(root)
	var foot_string: String = "0" + str(folder_id) + " Footage"
	foot_folder.set_text(0, foot_string)
	foot_folder.set_tooltip_text(0, "Contient les vidéos et photos produites à la production")
	for c in range(cameracount):
		for d in range(daycount):
			var tmp_f: TreeItem = tree.create_item(foot_folder)
			tmp_f.set_text(0, char(c + 65) + DataManager.daycount_int_to_string(d + 1))
			tmp_f.set_tooltip_text(0, "Caméra " + char(c + 65) + ", jour " + str(d + 1))
	folder_id += 1
	
	# VFX
	if use_vfx:
		var vfx_folder: TreeItem = tree.create_item(root)
		var vfx_string: String = "0" + str(folder_id) + " VFX"
		vfx_folder.set_text(0, vfx_string)
		vfx_folder.set_tooltip_text(0, "Contient tous les VFXs")
		folder_id += 1
	
	# Assets
	var assets_folder: TreeItem = tree.create_item(root)
	var assets_string: String = "0" + str(folder_id) + " Assets"
	assets_folder.set_text(0, assets_string)
	assets_folder.set_tooltip_text(0, "Les différents assets graphiques")
	var sub_assets_folder: TreeItem = tree.create_item(assets_folder)
	sub_assets_folder.set_text(0, "00 Drop-box")
	sub_assets_folder.set_tooltip_text(0, "Boîte de dépôt")
	sub_assets_folder = tree.create_item(assets_folder)
	sub_assets_folder.set_text(0, "01 Logo and branding")
	sub_assets_folder.set_tooltip_text(0, "Logos, polices d'écritures, ...")
	sub_assets_folder = tree.create_item(assets_folder)
	sub_assets_folder.set_text(0, "02 Branding guidelines")
	sub_assets_folder.set_tooltip_text(0, "Chartes graphiques")
	readme.drop_box = assets_string + "/00 Drop-box"
	folder_id += 1
	
	# Working renders
	var w_renders_folder: TreeItem = tree.create_item(root)
	var w_renders_string: String = "0" + str(folder_id) + " Working renders"
	w_renders_folder.set_text(0, w_renders_string)
	w_renders_folder.set_tooltip_text(0, "Rendus temporaires, de travail")
	var sub_w_renders_folder: TreeItem# = tree.create_item(w_renders_folder)
	if production_type == DataManager.ProductionType.EXTERNAL:
		sub_w_renders_folder = tree.create_item(w_renders_folder)
		sub_w_renders_folder.set_text(0, "Offline drafts")
		sub_w_renders_folder.set_tooltip_text(0, "Drafts pour l'équipe de réalisation, en interne")
		sub_w_renders_folder = tree.create_item(w_renders_folder)
		sub_w_renders_folder.set_text(0, "Online drafts")
		sub_w_renders_folder.set_tooltip_text(0, "Drafts pour le client")
		readme.working_renders = w_renders_string + "/Online drafts"
	elif production_type == DataManager.ProductionType.INTERNAL:
		sub_w_renders_folder = tree.create_item(w_renders_folder)
		sub_w_renders_folder.set_text(0, "Drafts")
		sub_w_renders_folder.set_tooltip_text(0, "Drafts pour révision")
		readme.working_renders = w_renders_string + "/Drafts"
	else:
		PrintUtility.print_error("Unknown production type : " + str(production_type))
	
	sub_w_renders_folder = tree.create_item(w_renders_folder)
	sub_w_renders_folder.set_text(0, "Process renders")
	sub_w_renders_folder.set_tooltip_text(0, "Rendus pour le montage ou les VFXs")
	sub_w_renders_folder = tree.create_item(w_renders_folder)
	sub_w_renders_folder.set_text(0, "Screenshots")
	sub_w_renders_folder.set_tooltip_text(0, "Captures d'écran")
	folder_id += 1
	
	# Final renders
	var f_renders_folder: TreeItem = tree.create_item(root)
	var f_renders_string: String = "0" + str(folder_id) + " Final renders"
	f_renders_folder.set_text(0, f_renders_string)
	f_renders_folder.set_tooltip_text(0, "Rendus finaux")
	readme.final_renders = f_renders_string
	folder_id += 1
	
	# Working edit files
	var w_edit_folder: TreeItem = tree.create_item(root)
	var w_edit_string: String = "0" + str(folder_id) + " Working edit files"
	w_edit_folder.set_text(0, w_edit_string)
	w_edit_folder.set_tooltip_text(0, "Fichiers temporaires du montage")
	folder_id += 1
	
	# DaVinci project archive
	var dv_archive_folder: TreeItem = tree.create_item(root)
	var dv_archive_string: String = "0" + str(folder_id) + " DaVinci project archive" if folder_id < 10 else str(folder_id) + " DaVinci project archive"
	dv_archive_folder.set_text(0, dv_archive_string)
	dv_archive_folder.set_tooltip_text(0, "Archive du projet DaVinci, une fois que le projet est terminé")
	folder_id += 1
	
	# Notes
	var notes_folder: TreeItem = tree.create_item(root)
	var notes_string: String = "0" + str(folder_id) + " Notes" if folder_id < 10 else str(folder_id) + " Notes"
	notes_folder.set_text(0, notes_string)
	notes_folder.set_tooltip_text(0, "Notes et PVs")
	var sub_notes_folder: TreeItem = tree.create_item(notes_folder)
	sub_notes_folder.set_text(0, "Director notes")
	sub_notes_folder.set_tooltip_text(0, "Notes du réalisateur·trice")
	sub_notes_folder = tree.create_item(notes_folder)
	sub_notes_folder.set_text(0, "Editor notes")
	sub_notes_folder.set_tooltip_text(0, "Notes du monteur·se")
	sub_notes_folder = tree.create_item(notes_folder)
	sub_notes_folder.set_text(0, "Production notes")
	sub_notes_folder.set_tooltip_text(0, "Notes de la production")
	sub_notes_folder = tree.create_item(notes_folder)
	sub_notes_folder.set_text(0, "PV and transcriptions")
	sub_notes_folder.set_tooltip_text(0, "PVs de réunions")
	readme.notes = notes_string
	folder_id += 1
	
	# Read-me
	var rm_folder: TreeItem = tree.create_item(root)
	var rm_string: String = "00 Vous etes ici - lisez-moi.txt"
	rm_folder.set_text(0, rm_string)
	folder_id += 1

func update_hovering() -> void:
	if main_scene.user_preferences.has_default_path and not info_locked and customer_name != "" and project_name != "" and production_type_option.selected != -1 and main_scene.user_preferences.show_highlights:
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
	
	var customer_editable = main_scene.user_preferences.has_default_path and not info_locked
	var project_name_editable = customer_editable and customer_name != ""# and is_customer_name_valid(customer_name)
	var production_type_editable = project_name_editable and project_name != ""# and is_project_name_valid(project_name)
	var editor_editable = production_type_editable and production_type_option.selected != -1
	var secondary_options_editable = editor_editable and editor_option.selected != -1
	
	# Choose folder button
	general_label.disable(info_locked)
	choose_folder_button.disabled = info_locked
	choose_folder_button.toggle_emphasis(not main_scene.user_preferences.has_default_path and not info_locked)
	choose_folder_label.disable(info_locked)
	choose_folder_result.text = main_scene.user_preferences.default_path
	choose_folder_result.tooltip_text = main_scene.user_preferences.default_path
	choose_folder_line.get_node("LineIcon").texture = main_scene.checked_texture if customer_editable else main_scene.empty_texture
	choose_folder_line.get_node("LineIcon").modulate = main_scene.checked_color
	
	# Customer name
	customer_label.disable(not customer_editable)
	customer_option.disabled = not customer_editable
	customer_option.toggle_emphasis(customer_editable and not project_name_editable)
	customer_edit.editable = customer_editable and customer_option.selected == 0
	customer_edit.toggle_emphasis(customer_editable and not project_name_editable)
	
	if customer_editable and customer_name != "" and is_customer_name_valid(customer_name):
		customer_edit.modulate = Color(1,1,1,1)
		customer_line.get_node("LineIcon").texture = main_scene.checked_texture
		customer_line.get_node("LineIcon").modulate = main_scene.checked_color
		customer_line.get_node("LineIcon").tooltip_text = ""
	else:
		if not is_customer_name_valid(customer_name):
			customer_edit.modulate = Color(1,0.5,0,1)
			customer_line.get_node("LineIcon").texture = main_scene.error_texture
			customer_line.get_node("LineIcon").modulate = main_scene.warning_color
			customer_line.get_node("LineIcon").tooltip_text = "Ce nom ne doit pas contenir de caractères spéciaux !"
		else:
			customer_line.get_node("LineIcon").texture = main_scene.checked_texture if project_name_editable else main_scene.empty_texture
			customer_line.get_node("LineIcon").modulate = main_scene.checked_color
			customer_line.get_node("LineIcon").tooltip_text = ""
	
	# Project name
	project_name_label.disable(not project_name_editable)
	project_name_edit.editable = project_name_editable
	project_name_edit.toggle_emphasis(project_name_editable and not production_type_editable)
	if project_name_editable and project_name != "" and is_project_name_valid(project_name):
		if path_has_conflict():
			project_name_edit.modulate = Color(1,0.5,0,1)
			project_name_line.get_node("LineIcon").texture = main_scene.error_texture
			project_name_line.get_node("LineIcon").modulate = main_scene.warning_color
			project_name_line.get_node("LineIcon").tooltip_text = "Un projet avec le même nom existe déjà pour ce client !"
		else:
			project_name_edit.modulate = Color(1,1,1,1)
			project_name_line.get_node("LineIcon").texture = main_scene.checked_texture
			project_name_line.get_node("LineIcon").modulate = main_scene.checked_color
			project_name_line.get_node("LineIcon").tooltip_text = ""
	else:
		if not is_project_name_valid(project_name):
			project_name_edit.modulate = Color(1,0.5,0,1)
			project_name_line.get_node("LineIcon").texture = main_scene.error_texture
			project_name_line.get_node("LineIcon").modulate = main_scene.warning_color
			project_name_line.get_node("LineIcon").tooltip_text = "Ce nom ne doit pas contenir de caractères spéciaux !"
		else:
			project_name_line.get_node("LineIcon").texture = main_scene.empty_texture
			project_name_line.get_node("LineIcon").modulate = main_scene.checked_color
			project_name_line.get_node("LineIcon").tooltip_text = ""
	#if not production_type_editable:
		#project_name_line.get_node("LineIcon").texture = main_scene.empty_texture
	
	# Production type
	production_type_label.disable(not production_type_editable)
	production_type_option.disabled = not production_type_editable
	production_type_option.toggle_emphasis(production_type_editable and not editor_editable)
	production_type_line.get_node("LineIcon").texture = main_scene.checked_texture if editor_editable else main_scene.empty_texture
	production_type_line.get_node("LineIcon").modulate = main_scene.checked_color
	
	# Editor name
	editor_label.disable(not editor_editable)
	editor_option.disabled = not editor_editable
	editor_option.toggle_emphasis(editor_editable and not secondary_options_editable)
	editor_edit.editable = editor_editable and editor_option.selected == 0
	editor_edit.toggle_emphasis(editor_editable and not secondary_options_editable)
	editor_line.get_node("LineIcon").texture = main_scene.checked_texture if secondary_options_editable else main_scene.empty_texture
	editor_line.get_node("LineIcon").modulate = main_scene.checked_color
	
	# Editor contact
	include_contact_label.disable(not secondary_options_editable)
	include_contact_checkbox.disabled = not secondary_options_editable
	include_contact_line.get_node("LineIcon").texture = main_scene.checked_texture if secondary_options_editable else main_scene.empty_texture
	include_contact_line.get_node("LineIcon").modulate = main_scene.checked_color
	
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
	#preview_folder_button.disabled = not (main_scene.user_preferences.has_default_path and customer_name != "" and project_name != "" and production_type_option.selected != -1 and editor_name != "" and not path_has_conflict())
	preview_folder_button.disabled = not can_preview()
	preview_folder_button.toggle_emphasis(secondary_options_editable)
	if can_preview():
		if can_generate():
			preview_folder_button.button_text = "Annuler"
		else:
			preview_folder_button.button_text = "Verrouiller et prévisualiser"
	generate_folder_button.disabled = not can_generate()
	
	# Tree
	if customer_name != "" and project_name != "":
		generate_folders_tree()
		summary_title.visible = true
		summary_body.visible = true
	else:
		folder_tree.clear()
		summary_title.visible = false
		summary_body.visible = false

func can_preview() -> bool:
	var is_customer_ok: bool = customer_name != "" and is_customer_name_valid(customer_name)
	var is_project_ok: bool = project_name != "" and is_project_name_valid(project_name) and not path_has_conflict()
	var is_production_type_ok: bool = production_type_option.selected != -1
	var is_editor_ok: bool = editor_name != ""
	return main_scene.user_preferences.has_default_path	and is_customer_ok and is_project_ok and is_production_type_ok and is_editor_ok
	

func can_generate() -> bool:
	return can_preview() and info_locked

func path_has_conflict() -> bool:
	return DirAccess.dir_exists_absolute(main_scene.user_preferences.default_path + "/" + customer_name + "/" + project_name)

func is_customer_name_valid(value: String) -> bool:
	var result: bool = true
	for i in range(value.length()):
		if not DataManager.is_alphanumerical(value.unicode_at(i), false):
			result = false
	return result

func is_project_name_valid(value: String) -> bool:
	var result: bool = true
	for i in range(value.length()):
		if not DataManager.is_alphanumerical(value.unicode_at(i), false):
			result = false
	return result

func build_customer_options() -> void:
	customer_option.clear()
	customer_option.add_item("<Nouveau client>")
	var new_customers: Array = []
	for i in range(main_scene.users.all_users.size()):
		if main_scene.users.all_users[i].function == DataManager.UserFunction.CUSTOMER:
			new_customers.append(main_scene.users.all_users[i].name)
	if main_scene.user_preferences.folder_follow_conventions:
		for d in DirAccess.get_directories_at(main_scene.user_preferences.default_path):
			if not main_scene.users.customer_exists(d):
				new_customers.append(d)
	
	new_customers.sort()
	for i in range(new_customers.size()):
		customer_option.add_item(new_customers[i])

func build_editor_options() -> void:
	editor_option.clear()
	for u in main_scene.users.all_users:
		if u.function == DataManager.UserFunction.EDITOR:
			editor_option.add_item(u.name)
	editor_option.selected = -1

func _on_choose_folder_button_pressed() -> void:
	PrintUtility.print_info("User trying to choose folder ...")
	get_node("FileDialog").set_current_dir(main_scene.user_preferences.default_path)
	get_node("FileDialog").visible = true

func _on_file_dialog_dir_selected(dir: String) -> void:
	PrintUtility.print_info("Selected folder is : " + dir + "/")
	main_scene.user_preferences.default_path = dir
	main_scene.user_preferences.has_default_path = true
	main_scene.user_preferences.save_to_file(main_scene.SAVE_PREFERENCES_PATH)
	build_customer_options()
	update_controls()

func _on_file_dialog_canceled() -> void:
	PrintUtility.print_info("User cancelled folder choice")

func _on_pre_generate_folder_button_pressed() -> void:
	info_locked = not info_locked
	
	if info_locked: PrintUtility.print_info("Start previewing folders ...")
	else: PrintUtility.print_info("Cancelled previewing folders")
	
	if info_locked:
		has_previewed = true
		preview_folder_button.text = "Annuler"
	else:
		preview_folder_button.text = "Verrouiller et prévisualiser"
	update_controls()

func _on_generate_folder_button_pressed() -> void:
	if not main_scene.users.customer_exists(customer_name):
		PrintUtility.print_gen("Saving new customer " + customer_name + " to file")
		main_scene.users.add_user(DataManager.UserFunction.CUSTOMER, customer_name, "", "")
		main_scene.users.save_to_file(main_scene.SAVE_USERS_PATH)
	else:
		PrintUtility.print_gen("Customer " + customer_name + " already present in user_preferences.customers, will not be saved")
	if not main_scene.users.editor_exists(editor_name):
		PrintUtility.print_gen("Using editor " + editor_name + " that doesn't exist in users.json")
		PrintUtility.print_error("Can't save editor through main workspace")
	else:
		PrintUtility.print_gen("Using existing editor, will not be saved")
	
	generation_has_issue = 0
	generation_issues = ""
	generate_system_folders()
	
	main_scene.user_manager.build_users()
	
	update_generation_completed_dialog()
	generation_completed_dialog.visible = true

func update_generation_completed_dialog() -> void:
	generation_completed_dialog.get_node("ScrollContainer/Label").text = "La génération du dossier :\n" + main_scene.user_preferences.default_path + "/" + customer_name + "/" + project_name
	if generation_has_issue > 0:
		generation_completed_dialog.get_node("ScrollContainer/Label").text += "\nNe s'est pas bien déroulée :(\n\n"
		generation_completed_dialog.get_node("ScrollContainer/Label").text += str(generation_has_issue) + " erreurs détectées ! Liste des erreurs :" + generation_issues
	else:
		generation_completed_dialog.get_node("ScrollContainer/Label").text += "\nS'est terminée avec succès. Le contenu a bien été généré."

func generate_system_folders() -> void:
	var main_path: String = main_scene.user_preferences.default_path
	var customer_path: String = main_path + "/" + customer_name
	var project_path: String = customer_path + "/" + project_name
	PrintUtility.print_info("Will generate folder here : " + project_path)
	var customer_result = DirAccess.make_dir_absolute(customer_path)
	match customer_result:
		0:
			PrintUtility.print_gen("New customer folder created at " + customer_path)
		32:
			PrintUtility.print_gen("Customer folder already exists " + customer_path)
		_:
			PrintUtility.print_gen("Unknown error : " + str(customer_result))
			generation_issues += "\nUnknown error (" + str(customer_result) + ") from main.generate_system_folders() with path " + customer_path
			generation_has_issue += 1
	
	if customer_result == 0 or customer_result == 32:
		var project_result = DirAccess.make_dir_absolute(project_path)
		match project_result:
			0:
				PrintUtility.print_gen("New project folder created at " + project_path)
			32:
				PrintUtility.print_gen("Project folder already exists " + project_path)
				PrintUtility.print_error("Can't create folder !")
				generation_issues += "\nError 32 from main.generate_system_folders() with path " + project_path
				generation_has_issue += 1
			_:
				PrintUtility.print_gen("Unkown error : " + str(project_result))
				generation_issues += "\nUnknown error (" + str(project_result) + ") from main.generate_system_folders() with path " + project_path
				generation_has_issue += 1
		if project_result == 0:
			generate_system_folders_project(project_path)

func generate_system_folders_project(path: String) -> void:
	PrintUtility.print_folders(folder_tree)
	
	var root: TreeItem = folder_tree.get_root()
	if root.get_child_count() > 0:
		for f in root.get_children():
			generate_folder_at(path + "/" + f.get_text(0))
			if f.get_child_count() > 0:
				for sf in f.get_children():
					generate_folder_at(path + "/" + f.get_text(0) + "/" + sf.get_text(0))
					if sf.get_child_count() > 0:
						for ssf in sf.get_children():
							generate_folder_at(path + "/" + f.get_text(0) + "/" + sf.get_text(0) + "/" + ssf.get_text(0))
							if ssf.get_child_count() > 0:
								for sssf in ssf.get_children():
									generate_folder_at(path + "/" + f.get_text(0) + "/" + sf.get_text(0) + "/" + ssf.get_text(0) + "/" + sssf.get_text(0))
									if sssf.get_child_count() > 0:
										PrintUtility.print_error("")
										generation_issues += "\nmain.generate_system_folders_project(" + path + ") didn't go deep enough in subfolders !"
										generation_has_issue += 1
	else:
		PrintUtility.print_error("Root of folder tree doesn't have any child ! ")
		generation_issues += "\nRoot of folder tree doesn't have any child in main.generate_system_folders_project(" + path + ")"
		generation_has_issue += 1

func generate_folder_at(path: String) -> void:
	PrintUtility.print_gen("Computing " + path)
	if path.contains("."):
		if path.ends_with(".txt"):
			var file_exist = FileAccess.file_exists(path)
			if file_exist:
				PrintUtility.print_gen("Readme file already exists " + path)
				PrintUtility.print_error("Can't create readme file")
				generation_issues += "\nReadme file already exists " + path
				generation_has_issue += 1
			else:
				var file = FileAccess.open(path, FileAccess.WRITE)
				match FileAccess.get_open_error():
					0:
						file.store_string(readme.generate_readme_content())
						PrintUtility.print_gen("Readme created at " + path)
					32:
						PrintUtility.print_gen("Readme file already exists " + path)
						PrintUtility.print_error("Can't create readme file")
						generation_issues += "\nError 32 from main.generate_folder_at() with path " + path
						generation_has_issue += 1
					_:
						PrintUtility.print_gen("Unknown error : " + str(FileAccess.get_open_error()))
						generation_issues += "\nUnknown error (" + str(FileAccess.get_open_error()) + ") from main.generate_system_folders() with path " + path
						generation_has_issue += 1
		else:
			PrintUtility.print_gen("Unkown file extension in generate_folder_at(" + path + ")")
			PrintUtility.print_error("Can't create file " + path)
			generation_issues += "\nUnkown file extension in main.generate_folder_at(" + path + ")"
			generation_has_issue += 1
	else:
		var result = DirAccess.make_dir_absolute(path)
		match result:
			0:
				PrintUtility.print_gen("New folder created at " + path)
			32:
				PrintUtility.print_gen("Folder already exists " + path)
				PrintUtility.print_error("Can't create folder " + path)
				generation_issues += "\nError 32, folder already exists : " + path
				generation_has_issue += 1
			_:
				PrintUtility.print_gen("Unkown error in generate_folder_at(" + path + ") : " + str(result))
				PrintUtility.print_error("Can't create folder " + path)
				generation_issues += "\nUnknown error (" + str(result) + ") from main.generate_folder_at(" + path + ")"
				generation_has_issue += 1

func reset_project() -> void:
	PrintUtility.print_info("Starting new project ...")
	customer_name = ""
	customer_option.selected = 0
	customer_edit.text = ""
	
	project_name = ""
	project_name_edit.text = ""
	project_name_edit.modulate = Color(1,1,1,1)
	production_type_option.selected = -1
	
	editor_name = ""
	editor_option.selected = -1
	editor_edit.text = ""
	
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
	preview_folder_button.text = "Verrouiller et prévisualiser"
	update_controls()

func update_line_icon(line, value: bool) -> void:
	line.get_node("LineIcon").texture = main_scene.empty_texture if value else main_scene.information_texture
	line.get_node("LineIcon").tooltip_text = "" if value else "Cette valeur a été modifiée"

# Form signals ====================================================================================

func _on_customer_option_item_selected(index: int) -> void:
	if index == 0:
		customer_name = customer_edit.text
	else:
		customer_name = customer_option.get_item_text(index)
	update_controls()

func _on_customer_edit_text_changed(new_text: String) -> void:
	customer_name = new_text
	update_controls()

func _on_project_name_edit_text_changed(new_text: String) -> void:
	project_name = new_text
	update_controls()

func _on_production_type_option_item_selected(index: int) -> void:
	match index:
		0:
			production_type = DataManager.ProductionType.EXTERNAL
		1:
			production_type = DataManager.ProductionType.INTERNAL
	update_controls()

func _on_editor_option_item_selected(index: int) -> void:
	if index != -1:
		editor_name = editor_option.get_item_text(index)
	update_controls()

func _on_editor_edit_text_changed(new_text: String) -> void:
	editor_name = new_text
	update_controls()

func _on_include_contact_option_toggled(toggled_on: bool) -> void:
	use_contact = toggled_on
	update_controls()

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

func _on_generation_completed_dialog_confirmed() -> void:
	if generation_has_issue > 0:
		generation_has_issue = 0
		generation_issues = ""
		info_locked = false
		update_controls()
		PrintUtility.print_info("Automatic cancelled previewing folders")
		preview_folder_button.text = "Verrouiller et prévisualiser"
	else:
		generation_has_issue = 0
		generation_issues = ""
		build_customer_options()
		build_editor_options()
		reset_project()
