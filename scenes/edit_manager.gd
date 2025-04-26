extends Control

var main_scene

@onready var project_summary = get_node("HBoxContainer/VBoxContainer/ProjectSummary")
@onready var timecode_notes = get_node("HBoxContainer/VBoxContainer/TimecodeNotes")

var project_name: String = ""
var customer_name: String = ""
var previous_version_id: int = 0
var version_id: int = 0
var version_name: String = ""
var md_file_path: String = ""
var use_hour: bool = false

func init(scene) -> void:
	main_scene = scene
	if main_scene.user_preferences.has_default_path:
		get_node("FileDialog").current_dir = main_scene.user_preferences.default_path
	if main_scene.user_preferences.last_edit_manager_path != "":
		_on_file_dialog_dir_selected(main_scene.user_preferences.last_edit_manager_path)
	get_node("HBoxContainer/MDViewer").visible = main_scene.user_preferences.show_previous_version
	get_node("HBoxContainer/VBoxContainer/CheckButton").button_pressed = main_scene.user_preferences.show_previous_version
	timecode_notes.init(main_scene, self)

func _ready() -> void:
	project_summary.open_folder.connect(_on_open_folder_pressed)

func generate_notes_string() -> String:
	var s: String = ""
	s += "# " + version_name
	if get_node("HBoxContainer/VBoxContainer/GeneralEdit").text != "":
		s += new_line()
		s += get_node("HBoxContainer/VBoxContainer/GeneralEdit").text
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
					if get_node("HBoxContainer/VBoxContainer/HBoxContainer/CheckBox").button_pressed:
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
				s += " "
			s += c.text
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

func get_versions_list(project_path: String) -> Array:
	var versions: Array = []
	var found_drafts_folder: bool = false
	var drafts_folder: String = ""
	
	for d in DirAccess.get_directories_at(project_path):
		if d.contains("Working renders"):
			if DirAccess.dir_exists_absolute(project_path + "/" + d + "/Online drafts"):
				found_drafts_folder = true
				drafts_folder = project_path + "/" + d + "/Online drafts"
	if found_drafts_folder:
		for f in DirAccess.get_files_at(drafts_folder):
			if f.ends_with(".mp4") or f.ends_with(".MP4"):
				for s in f.get_file().get_basename().split(" "):
					if s.begins_with("v") and (s.length() <= 4):
						versions.append(int(s))
		versions.sort()
		versions.reverse()
		
		var loop_count: int = 0
		
		while loop_count < 100:
			var current = versions.pop_front()
			if current == version_id:
				if versions.size() >= 1:
					find_previous_edit_version(drafts_folder, versions.pop_front())
				break
			loop_count += 1
	
	return versions

func find_previous_edit_version(folder: String, version: int) -> void:
	PrintUtility.print_info("Searching previous version notes v" + str(version))
	var result: String = ""
	var parsing_previous: bool = false
	var found_previous: bool = false
	for f in DirAccess.get_files_at(folder):
		if f.ends_with(".md"):
			var file = FileAccess.open(folder + "/" + f, FileAccess.READ_WRITE)
			var content = FileAccess.get_file_as_string(folder + "/" + f)
			for line in content.split("\n", false, 0):
				
				if parsing_previous:
					if line != "---" and not line.begins_with("#"):
						result += "\n" + line
				
				if line.length() >= 4:
					if line.begins_with("#"):
						var line_elements = line.split(" ")
						line_elements.remove_at(0)
						while line_elements.size() > 0:
							var tmp_line_element: String = line_elements[0]
							if tmp_line_element.length() <= 4:
								if tmp_line_element.begins_with("v"):
									var version_string = tmp_line_element.erase(0, 1)
									if int(version_string) == version:
										parsing_previous = true
										found_previous = true
										result += line
										break
									else:
										parsing_previous = false
							line_elements.remove_at(0)
	if not found_previous:
		result = "Aucune note pour la version précédente"
	get_node("HBoxContainer/MDViewer").text = result
	get_node("HBoxContainer/MDViewer").parse_md_file()

func find_last_edit_version(project_path: String) -> void:
	var name_result: String = ""
	var suffix_result: String = ""
	var found_drafts_folder: bool = false
	var drafts_folder: String = ""
	for d in DirAccess.get_directories_at(project_path):
		if d.contains("Working renders"):
			if DirAccess.dir_exists_absolute(project_path + "/" + d + "/Online drafts"):
				found_drafts_folder = true
				drafts_folder = project_path + "/" + d + "/Online drafts"
	if found_drafts_folder:
		var versions: Array = []
		for f in DirAccess.get_files_at(drafts_folder):
			if f.ends_with(".mp4") or f.ends_with(".MP4"):
				for s in f.get_file().get_basename().split(" "):
					if s.begins_with("v") and (s.length() <= 4):
						versions.append(int(s))
		versions.sort()
		version_id = versions.pop_back()
		name_result = "Version v" + str(version_id)
	else:
		PrintUtility.print_error("Didn't found drafts folder in project path " + project_path)
	
	version_name = name_result
	project_summary.set_version_name(name_result)

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

func show_ids(is_visible: bool) -> void:
	for c in timecode_notes.notes_container.get_children():
		c.get_node("Label").visible = is_visible

func print_notes() -> void:
	PrintUtility.print_info("Currently " + str(timecode_notes.notes_container.get_child_count()) + " TimecodeNotes and " + str(timecode_notes.notes.notes.size()) + " EditNotes")
	PrintUtility.print_info("Current notes are :")
	if timecode_notes.notes.notes.size() > 0:
		print("----------------------------------------------------------------")
		for n in timecode_notes.notes.notes:
			if n.has_timecode():
				print(str(n.note_id) + " " + formatted_timecode_binome(n.hour) + ":" + formatted_timecode_binome(n.minute) + ":" + formatted_timecode_binome(n.second) + ":" + formatted_timecode_binome(n.frame) + " " + n.text)
			else:
				print(str(n.note_id) + "             " + n.text)
		print("----------------------------------------------------------------")
	else:
		print("No note")

# Signals -----------------------------------------------------------------------------------------

func _on_open_folder_pressed() -> void:
	get_node("FileDialog").visible = true

func _on_file_dialog_dir_selected(dir: String) -> void:
	for d in DirAccess.get_directories_at(dir):
		if d.contains("Working renders"):
			if DirAccess.dir_exists_absolute(dir + "/" + d + "/Online drafts"):
				md_file_path = dir + "/" + d + "/Online drafts"
	project_name = get_dir_name(dir)
	project_summary.set_project_name(get_dir_name(dir))
	customer_name = get_dir_name(get_parent_path(dir))
	project_summary.set_customer_name(get_dir_name(get_parent_path(dir)))
	find_last_edit_version(dir)
	get_versions_list(dir)
	
	main_scene.user_preferences.last_edit_manager_path = dir
	main_scene.user_preferences.save_to_file(main_scene.SAVE_PREFERENCES_PATH)

func _on_button_pressed() -> void:
	write_to_file()

func _on_check_box_toggled(toggled_on: bool) -> void:
	timecode_notes.update_hour_slot(toggled_on)
	use_hour = toggled_on

func _on_sort_button_pressed() -> void:
	timecode_notes.sort_notes_by_time()

func _on_check_button_toggled(toggled_on: bool) -> void:
	get_node("HBoxContainer/MDViewer").visible = toggled_on
	main_scene.user_preferences.show_previous_version = toggled_on
	main_scene.user_preferences.save_to_file(main_scene.SAVE_PREFERENCES_PATH)
