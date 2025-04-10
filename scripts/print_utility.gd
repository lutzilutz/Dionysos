extends Node
class_name PrintUtility

static func print_TODO(text: String) -> void:
	printt("[TODO]", "",  text)

static func print_WIP(text: String) -> void:
	printt("[WIP]", "", text)

static func print_info(text: String) -> void:
	printt("[INFO]", "", text)

static func print_error(text: String) -> void:
	printt("[ERROR]", "", text)

static func print_signal(text: String) -> void:
	printt("[SIGNAL]", text)

static func print_gen(text: String) -> void:
	printt("[GEN]", "", text)

static func print_folders(tree: Tree) -> void:
	PrintUtility.print_info("Current folders tree is :")
	print("----------------------------------------------------------------")
	var tab: String = "\t"
	if tree.get_root():
		print("Root")
		if tree.get_root().get_child_count() > 0:
			for f: TreeItem in tree.get_root().get_children():
				print(tab + f.get_text(0))
				if f.get_child_count() > 0:
					for sf: TreeItem in f.get_children():
						print(tab + tab + sf.get_text(0))
						if sf.get_child_count() > 0:
							for ssf: TreeItem in sf.get_children():
								print(tab + tab + tab + ssf.get_text(0))
								if ssf.get_child_count() > 0:
									for sssf: TreeItem in ssf.get_children():
										print(tab + tab + tab + tab + sssf.get_text(0))
										if sssf.get_child_count() > 0:
											PrintUtility.print_error("print_folders() didn't go deep enough, still folders to print")
	print("----------------------------------------------------------------")

static func print_user(user: User) -> void:
	if user == null:
		print_info("User is null !")
	else:
		print_info("User is :")
		print("----------------------------------------------------------------")
		print(user.name)
		print(user.function)
		print(user.phone)
		print(user.email)
		print("----------------------------------------------------------------")
