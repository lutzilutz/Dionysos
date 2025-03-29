extends Node
class_name PrintUtility

static func print_TODO(text: String) -> void:
	printt("[TODO] ", text)

static func print_WIP(text: String) -> void:
	printt("[WIP]  ", text)

static func print_info(text: String) -> void:
	printt("[INFO] ", text)

static func print_error(text: String) -> void:
	printt("[ERROR]", text)
