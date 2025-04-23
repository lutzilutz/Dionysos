extends Control

var main_scene

@onready var project_summary = get_node("VBoxContainer/ProjectSummary")
@onready var timecode_notes = get_node("VBoxContainer/TimecodeNotes")

var project_name: String = ""
var customer_name: String = ""
var version_name: String = ""
#var version_suffix: String = ""
var md_file_path: String = ""
var use_hour: bool = false

func init(scene) -> void:
	main_scene = scene
	if main_scene.user_preferences.has_default_path:
		get_node("FileDialog").current_dir = main_scene.user_preferences.default_path
	if main_scene.user_preferences.last_edit_manager_path != "":
		_on_file_dialog_dir_selected(main_scene.user_preferences.last_edit_manager_path)
	timecode_notes.init(self)

func _ready() -> void:
	project_summary.open_folder.connect(_on_open_folder_pressed)

func generate_notes_string() -> String:
	var s: String = ""
	s += "# " + version_name
	if get_node("VBoxContainer/GeneralEdit").text != "":
		s += new_line()
		s += get_node("VBoxContainer/GeneralEdit").text
	if timecode_notes.notes.notes.size() > 0:
		s += new_line()
		s += "Liste des modifications :"
		PrintUtility.print_gen("Generating " + str(timecode_notes.notes.notes.size()) + " notes ...")
		for c in timecode_notes.notes.notes:
			s += "\n - "
			if c.has_timecode():
				if c.hour > 0:
					s += formatted_timecode_binome(c.hour) + ":"
				else:
					if get_node("VBoxContainer/HBoxContainer/CheckBox").button_pressed:
						s += "00:"
				if c.minute > 0:
					s += formatted_timecode_binome(c.minute) + ":"
				else:
					s += "00:"
				if c.second > 0:
					s += formatted_timecode_binome(c.second) + ":"
				else:
					s += "00:"
				if c.frame > 0:
					s += formatted_timecode_binome(c.frame)
				else:
					s += "00"
	else:
		PrintUtility.print_gen("No timecode notes found")
	return s

func formatted_timecode_binome(value: int) -> String:
	var result: String = ""
	if value < 10:
		result += "0"
	result += str(value)
	return result

func new_line() -> String:
	return "\n\n"

func write_to_file() -> void:
	var file_path: String = md_file_path + "/Informations sur les versions.md"
	var file_exist = FileAccess.file_exists(file_path)
	if file_exist:
		PrintUtility.print_gen("File already exists")
	else:
		PrintUtility.print_gen("New md file")
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		file.close()
	var notes_string: String = generate_notes_string()
	var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	file.seek_end(0)
	match FileAccess.get_open_error():
		0:
			PrintUtility.print_gen("MD successfully opened at " + file_path)
			if file.get_length() > 0:
				file.store_string(new_line() + "---" + new_line() + notes_string)
			else:
				file.store_string(notes_string)
		_:
			PrintUtility.print_gen(file_path)
			PrintUtility.print_gen("Unknown error : " + str(FileAccess.get_open_error()))

func _on_open_folder_pressed() -> void:
	get_node("FileDialog").visible = true

func find_last_edit_version(project_path: String) -> void:
	var name_result: String = ""
	var suffix_result: String = ""
	var found_drafts_folder: bool = false
	var drafts_folder: String = ""
	for d in DirAccess.get_directories_at(project_path):
		if d.contains("Working renders"):
			if DirAccess.dir_exists_absolute(project_path + "/" + d + "/Online drafts"):
				PrintUtility.print_info("Found online drafts folder of project")
				found_drafts_folder = true
				drafts_folder = project_path + "/" + d + "/Online drafts"
	if found_drafts_folder:
		var versions: Array = []
		for f in DirAccess.get_files_at(drafts_folder):
			if f.ends_with(".mp4") or f.ends_with(".MP4"):
				for s in f.get_file().get_basename().split(" "):
					if s.begins_with("v") and (s.length() == 3 or s.length() == 4):
						versions.append(int(s))
		versions.sort()
		#for f in DirAccess.get_files_at(drafts_folder):
			#if f.ends_with(".mp4") or f.ends_with(".MP4"):
				#if f.contains("v"+ str(versions.pop_back()):
					#f.split(" ").
		name_result = "Version v" + str(versions.pop_back())
	else:
		PrintUtility.print_error("Didn't found drafts folder in project path " + project_path)
	
	version_name = name_result
	project_summary.set_version_name(name_result)

func _on_file_dialog_dir_selected(dir: String) -> void:
	for d in DirAccess.get_directories_at(dir):
		if d.contains("Working renders"):
			if DirAccess.dir_exists_absolute(dir + "/" + d + "/Online drafts"):
				PrintUtility.print_info("Found online drafts folder of project")
				md_file_path = dir + "/" + d + "/Online drafts"
	project_name = get_dir_name(dir)
	project_summary.set_project_name(get_dir_name(dir))
	customer_name = get_dir_name(get_parent_path(dir))
	project_summary.set_customer_name(get_dir_name(get_parent_path(dir)))
	find_last_edit_version(dir)
	
	main_scene.user_preferences.last_edit_manager_path = dir
	main_scene.user_preferences.save_to_file(main_scene.SAVE_PREFERENCES_PATH)

func get_dir_name(path: String) -> String:
	var path_dirs = path.split("/")
	for i in range(0, path_dirs.size()):
		if i == path_dirs.size()-1:
			return path_dirs[i]
	return ""

func get_parent_path(path: String) -> String:
	var path_dirs = path.split("/")
	var parent_path: String = ""
	for i in range(0, path_dirs.size()):
		if i < path_dirs.size()-1:
			parent_path += path_dirs[i]
			if i < path_dirs.size()-2:
				parent_path += "/"
	return parent_path

func _on_button_pressed() -> void:
	write_to_file()

func _on_check_box_toggled(toggled_on: bool) -> void:
	timecode_notes.update_hour_slot(toggled_on)
	use_hour = toggled_on
