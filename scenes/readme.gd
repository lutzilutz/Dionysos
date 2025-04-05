class_name ReadMe extends Node

var main_scene
var working_renders: String = ""
var final_renders: String = ""
var drop_box: String = ""
var notes: String = ""

func generate_readme_content() -> String:
	var s: String = ""
	s += generate_intro()
	s += generate_important()
	s += generate_team()
	s += generate_details()
	s += generate_map()
	return s

func generate_intro() -> String:
	var s: String = "Bienvenue dans le dossier du projet \"" + main_scene.project_name + "\" de " + main_scene.customer_name + "."
	s += add_line(0, "Vous trouverez ci-dessous des indications sur la structure du projet et les emplacements intéressants.")
	s += add_line(0, "Pour toute question d'ordre technique, merci de bien vouloir écrire à : lutz@drykats.ch")
	return s

func generate_important() -> String:
	var s: String = ""
	s += add_section("Important")
	s += add_line(1, "Vidéos temporaires : " + working_renders)
	s += add_line(1, "Vidéos finales : " + final_renders)
	if main_scene.production_type == main_scene.ProductionType.EXTERNAL:
		s += add_line(1, "Pour nous transmettre vos logos : " + drop_box)
	return s

func generate_team() -> String:
	var s: String = ""
	s += add_section("Équipe")
	s += add_subsection("Montage")
	s += add_line(2, "Monteur : " + main_scene.editor_name)
	if main_scene.use_contact:
		s += add_line(2, "Téléphone : " + main_scene.users.get_user_from_name(DataManager.UserFunction.EDITOR, main_scene.editor_name).phone)
		s += add_line(2, "E-mail : " + main_scene.users.get_user_from_name(DataManager.UserFunction.EDITOR, main_scene.editor_name).email)
	return s

func generate_details() -> String:
	var s: String = ""
	s += add_section("Divers")
	s += add_subsection("Logos et chartes")
	s += add_line(2, "Vous pouvez déposer à tout moment vos logos et chartes graphiques à l'emplacement : " + drop_box)
	s += add_line(2, "Formats idéaux : PNG, PDF, PS, BMP")
	s += add_line(2, "Formats à éviter : JPG/JPEG, GIF")
	s += add_subsection("Rendus")
	s += add_line(2, "Nous utilisons une numérotation séquentielle pour les versions : v01, v02, v03, ...")
	s += add_line(2, "Cette numérotation est présente dans les noms de fichier ainsi que dans les vidéos.")
	s += add_subsection("Notes")
	s += add_line(2, "Le dossier \"" + notes + "\" peut contenir vos notes, retours, indications, ou PV de réunion.")
	return s

func generate_map() -> String:
	var s: String = ""
	s += add_section("Plan")
	
	if main_scene.folder_tree.get_root():
		if main_scene.folder_tree.get_root().get_child_count() > 0:
			for f: TreeItem in main_scene.folder_tree.get_root().get_children():
				s += add_map_folder(0, f.get_text(0)) + f.get_tooltip_text(0)
				if f.get_child_count() > 0:
					for sf: TreeItem in f.get_children():
						s += add_map_folder(1, sf.get_text(0)) + sf.get_tooltip_text(0)
						if sf.get_child_count() > 0:
							for ssf: TreeItem in sf.get_children():
								s += add_map_folder(2, ssf.get_text(0)) + ssf.get_tooltip_text(0)
								if ssf.get_child_count() > 0:
									for sssf: TreeItem in ssf.get_children():
										s += add_map_folder(3, sssf.get_text(0)) + sssf.get_tooltip_text(0)
										if sssf.get_child_count() > 0:
											PrintUtility.print_error("generate_map() didn't go deep enough, still folders to print")
	return s

func add_line(tabs: int, s: String) -> String:
	var tabs_s: String = ""
	for i in range(tabs):
		tabs_s += "     "
	return "\n" + tabs_s + s

func add_map_folder(tabs: int, s: String) -> String:
	var result: String = ""
	var tabs_s: String = ""
	for i in range(tabs):
		tabs_s += "     "
	result = "\n" + tabs_s + s
	while result.length() < 70:
		result += " "
	return result

func add_section(s: String) -> String:
	return "\n" + add_line(0, "========== " + s + " ==========")

func add_subsection(s: String) -> String:
	return "\n" + add_line(1, "----- " + s + " -----")
