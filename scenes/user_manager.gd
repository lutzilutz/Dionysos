extends Control

signal users_changed

var main_scene
var modified_user: String = ""

var UserItem = preload("res://scenes/user_item.tscn")
@onready var users_container = get_node("VBoxContainer/UsersScroll/UsersVBox")

func build_users() -> void:
	if main_scene.user_preferences.editors.size() == 0:
		print("No user")
	
	for u in users_container.get_children():
		u.queue_free()
	
	for u in main_scene.user_preferences.editors:
		#print(u.name)
		var tmp_user = UserItem.instantiate()
		tmp_user.change_user(u.name, u.phone, u.email)
		tmp_user.ask_deletion.connect(_on_user_item_ask_deletion)
		users_container.add_child(tmp_user)
	
	#print(users_container.get_child_count())

func _on_close_button_pressed() -> void:
	self.visible = false

func _on_user_item_ask_deletion(text: String) -> void:
	modified_user = text
	get_node("AcceptDialog/Label").text = "Oui non ? " + modified_user
	get_node("AcceptDialog").visible = true

func delete_user(text: String) -> void:
	var deletion_index: int = -1
	for i in range(main_scene.user_preferences.editors.size()):
		if main_scene.user_preferences.editors[i].name == text:
			deletion_index = i
	if deletion_index == -1:
		PrintUtility.print_error("UserManager.delete_user(" + text + ") failed, no user with this name found in main_scene.user_preferences.editors")
	else:
		main_scene.user_preferences.editors.remove_at(deletion_index)

func _on_accept_dialog_confirmed() -> void:
	delete_user(modified_user)
	build_users()
	users_changed.emit()

func _on_accept_dialog_canceled() -> void:
	pass # Replace with function body.
