extends Control

var main_scene

@onready var project_summary = get_node("VBoxContainer/ProjectSummary")

func init(scene) -> void:
	main_scene = scene
	if main_scene.user_preferences.has_default_path:
		get_node("FileDialog").current_dir = main_scene.user_preferences.default_path

func _ready() -> void:
	project_summary.open_folder.connect(_on_open_folder_pressed)

func _on_open_folder_pressed() -> void:
	get_node("FileDialog").visible = true

func find_last_edit_version(project_path: String) -> String:
	var result: String = ""
	var found_drafts_folder: bool = false
	var drafts_folder: String = ""
	for d in DirAccess.get_directories_at(project_path):
		if d.contains("Working renders"):
			if DirAccess.dir_exists_absolute(project_path + "/" + d + "/Online drafts"):
				PrintUtility.print_info("Found online drafts folder of project")
				found_drafts_folder = true
				drafts_folder = project_path + "/" + d + "/Online drafts"
	if found_drafts_folder:
		#print(drafts_folder)
		var versions: Array = []
		for f in DirAccess.get_files_at(drafts_folder):
			if f.ends_with(".mp4") or f.ends_with(".MP4"):
				#versions.append(f.get_file().get_basename())
				for s in f.get_file().get_basename().split(" "):
					if s.begins_with("v") and (s.length() == 3 or s.length() == 4):
						versions.append(int(s))
			#print(f)
		versions.sort()
		print("Versions : ")
		print(versions)
		result = "Version v" + str(versions.pop_back())
	else:
		PrintUtility.print_error("Didn't found drafts folder in project path " + project_path)
	return result

func _on_file_dialog_dir_selected(dir: String) -> void:
	for d in DirAccess.get_directories_at(dir):
		if d.contains("Working renders"):
			if DirAccess.dir_exists_absolute(dir + "/" + d + "/Online drafts"):
				PrintUtility.print_info("Found online drafts folder of project")
	project_summary.set_project_name(get_dir_name(dir))
	project_summary.set_customer_name(get_dir_name(get_parent_path(dir)))
	project_summary.set_version_name(find_last_edit_version(dir))

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
	
